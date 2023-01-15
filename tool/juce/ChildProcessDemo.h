/*
  ==============================================================================

   This file is part of the JUCE examples.
   Copyright (c) 2022 - Raw Material Software Limited

   The code included in this file is provided under the terms of the ISC license
   http://www.isc.org/downloads/software-support-policy/isc-license. Permission
   To use, copy, modify, and/or distribute this software for any purpose with or
   without fee is hereby granted provided that the above copyright notice and
   this permission notice appear in all copies.

   THE SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY WARRANTY, AND ALL WARRANTIES,
   WHETHER EXPRESSED OR IMPLIED, INCLUDING MERCHANTABILITY AND FITNESS FOR
   PURPOSE, ARE DISCLAIMED.

  ==============================================================================
*/

/*******************************************************************************
 The block below describes the properties of this PIP. A PIP is a short snippet
 of code that can be read by the Projucer and used to generate a JUCE project.

 BEGIN_JUCE_PIP_METADATA

 name:             ChildProcessDemo
 version:          1.0.0
 vendor:           JUCE
 website:          http://juce.com
 description:      Launches applications as child processes.

 dependencies:     juce_core, juce_data_structures, juce_events, juce_graphics,
                   juce_gui_basics
 exporters:        xcode_mac, vs2022, linux_make

 moduleFlags:      JUCE_STRICT_REFCOUNTEDPOINTER=1

 type:             Console
 mainClass:        ChildProcessDemo

 useLocalCopy:     1

 END_JUCE_PIP_METADATA

*******************************************************************************/

#pragma once

#include "DemoUtilities.h"
#include <filesystem>

//==============================================================================
// This is a token that's used at both ends of our parent-child processes, to
// act as a unique token in the command line arguments.
static const char* demoCommandLineUID = "demoUID";

// A few quick utility functions to convert between raw data and ValueTrees
static ValueTree memoryBlockToValueTree (const MemoryBlock& mb)
{
    return ValueTree::readFromData (mb.getData(), mb.getSize());
}

static MemoryBlock valueTreeToMemoryBlock (const ValueTree& v)
{
    MemoryOutputStream mo;
    v.writeToStream (mo);

    return mo.getMemoryBlock();
}

static String valueTreeToString (const ValueTree& v)
{
    if (auto xml = v.createXml())
        return xml->toString (XmlElement::TextFormat().singleLine().withoutHeader());

    return {};
}

//==============================================================================
class ChildProcessDemo   : public Component,
                           private MessageListener
{
public:
    ChildProcessDemo()
    {
        setOpaque (true);

        addAndMakeVisible (launchButton);
        launchButton.onClick = [this] { launchChildProcess(); };

        addAndMakeVisible (pingButton);
        pingButton.onClick = [this] { pingChildProcess(); };

        addAndMakeVisible (killButton);
        killButton.onClick = [this] { killChildProcess(); };

        addAndMakeVisible (testResultsBox);
        testResultsBox.setMultiLine (true);
        testResultsBox.setFont ({ Font::getDefaultMonospacedFontName(), 12.0f, Font::plain });

        logMessage (String ("This demo uses the ChildProcessCoordinator and ChildProcessWorker classes to launch and communicate "
                            "with a child process, sending messages in the form of serialised ValueTree objects.") + newLine
                  + String ("In this demo, the child process will automatically quit if it fails to receive a ping message at least every ")
                  + String (timeoutSeconds)
                  + String (" seconds. To keep the process alive, press the \"")
                  + pingButton.getButtonText()
                  + String ("\" button periodically.") + newLine);

        setSize (500, 500);
    }

    ~ChildProcessDemo() override
    {
        coordinatorProcess.reset();
    }

    void paint (Graphics& g) override
    {
        g.fillAll (getUIColourIfAvailable (LookAndFeel_V4::ColourScheme::UIColour::windowBackground));
    }

    void resized() override
    {
        auto area = getLocalBounds();

        auto top = area.removeFromTop (40);
        launchButton.setBounds (top.removeFromLeft (180).reduced (8));
        pingButton  .setBounds (top.removeFromLeft (180).reduced (8));
        killButton  .setBounds (top.removeFromLeft (180).reduced (8));

        testResultsBox.setBounds (area.reduced (8));
    }

    // Appends a message to the textbox that's shown in the demo as the console
    void logMessage (const String& message)
    {
        postMessage (new LogMessage (message));
    }

    // invoked by the 'launch' button.
    void launchChildProcess()
    {
        if (coordinatorProcess.get() == nullptr)
        {
            auto currentPath = File::getSpecialLocation(File::currentExecutableFile);
            std::filesystem::path childProcessPath{ currentPath.getFullPathName().toStdString() };
            // get to the root of the project
            childProcessPath /= "../../../../../..";
            // get to the flutter executable
            childProcessPath /= "example/build/linux/x64/release/bundle/juce_ipc_example";
            childProcessPath = childProcessPath.lexically_normal();

            if(!std::filesystem::exists(childProcessPath))
            {
                logMessage("The child exectuable doesn't exist in the file "
                        "system. Did you build the example in release mode "
                        "using flutter? I was looking for it at the following "
                        "path:");
                logMessage(childProcessPath.string());
            }

            coordinatorProcess = std::make_unique<DemoCoordinatorProcess> (*this);
            if (coordinatorProcess->launchWorkerProcess ({childProcessPath.string()},
                                                         demoCommandLineUID,
                                                         timeoutMillis))
            {
                logMessage ("Child process started");
            }
            else
            {
                logMessage ("Failed to start child process");
            }
        }
    }

    // invoked by the 'ping' button.
    void pingChildProcess()
    {
        if (coordinatorProcess.get() != nullptr)
            coordinatorProcess->sendPingMessageToWorker();
        else
            logMessage ("Child process is not running!");
    }

    // invoked by the 'kill' button.
    void killChildProcess()
    {
        if (coordinatorProcess.get() != nullptr)
        {
            coordinatorProcess.reset();
            logMessage ("Child process killed");
        }
    }

    //==============================================================================
    // This class is used by the main process, acting as the coordinator and receiving messages
    // from the worker process.
    class DemoCoordinatorProcess  : public ChildProcessCoordinator,
                                    private DeletedAtShutdown,
                                    private AsyncUpdater
    {
    public:
        DemoCoordinatorProcess (ChildProcessDemo& d) : demo (d) {}

        ~DemoCoordinatorProcess() override { cancelPendingUpdate(); }

        // This gets called when a message arrives from the worker process..
        void handleMessageFromWorker (const MemoryBlock& mb) override
        {
            auto incomingMessage = memoryBlockToValueTree (mb);

            demo.logMessage ("Received: " + valueTreeToString (incomingMessage));
        }

        // This gets called if the worker process dies.
        void handleConnectionLost() override
        {
            demo.logMessage ("Connection lost to child process!");
            triggerAsyncUpdate();
        }

        void handleAsyncUpdate() override
        {
            demo.killChildProcess();
        }

        void sendPingMessageToWorker()
        {
            ValueTree message ("MESSAGE");
            message.setProperty ("count", count++, nullptr);

            demo.logMessage ("Sending: " + valueTreeToString (message));

            sendMessageToWorker (valueTreeToMemoryBlock (message));
        }

        ChildProcessDemo& demo;
        int count = 0;
    };

    //==============================================================================
    std::unique_ptr<DemoCoordinatorProcess> coordinatorProcess;

    static constexpr auto timeoutSeconds = 1;
    static constexpr auto timeoutMillis = timeoutSeconds * 1000;

private:

    TextButton launchButton  { "Launch Child Process" };
    TextButton pingButton    { "Send Ping" };
    TextButton killButton    { "Kill Child Process" };

    TextEditor testResultsBox;

    struct LogMessage  : public Message
    {
        LogMessage (const String& m) : message (m) {}

        String message;
    };

    void handleMessage (const Message& message) override
    {
        testResultsBox.moveCaretToEnd();
        testResultsBox.insertTextAtCaret (static_cast<const LogMessage&> (message).message + newLine);
        testResultsBox.moveCaretToEnd();
    }

    void lookAndFeelChanged() override
    {
        testResultsBox.applyFontToAllText (testResultsBox.getFont());
    }

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (ChildProcessDemo)
};

//==============================================================================
// As we need to modify the JUCEApplication::initialise method to launch the child process
// based on the command line parameters, we can't just use the normal auto-generated Main.cpp.
// Instead, we don't do anything in Main.cpp and create a JUCEApplication subclass here with
// the necessary modifications.
class Application    : public JUCEApplication
{
public:
    //==============================================================================
    Application() {}

    const String getApplicationName() override              { return "ChildProcessDemo"; }
    const String getApplicationVersion() override           { return "1.0.0"; }

    void initialise (const String& commandLine) override
    {
        mainWindow = std::make_unique<MainWindow> ("ChildProcessDemo", std::make_unique<ChildProcessDemo>());
    }

    void shutdown() override                                { mainWindow = nullptr; }

private:
    class MainWindow    : public DocumentWindow
    {
    public:
        MainWindow (const String& name, std::unique_ptr<Component> c)
           : DocumentWindow (name,
                             Desktop::getInstance().getDefaultLookAndFeel()
                                                   .findColour (ResizableWindow::backgroundColourId),
                             DocumentWindow::allButtons)
        {
            setUsingNativeTitleBar (true);
            setContentOwned (c.release(), true);

            centreWithSize (getWidth(), getHeight());

            setVisible (true);
        }

        void closeButtonPressed() override
        {
            JUCEApplication::getInstance()->systemRequestedQuit();
        }

    private:
        JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (MainWindow)
    };

    std::unique_ptr<MainWindow> mainWindow;
};

//==============================================================================
START_JUCE_APPLICATION (Application)
