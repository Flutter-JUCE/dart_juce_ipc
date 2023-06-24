import {AppConnection} from '@focusritegroup/juce-end-to-end';

describe('My app tests', () => {
    let appConnection: AppConnection;

    beforeEach(async () => {
        appConnection = new AppConnection({appPath: process.env.APP_PATH});
        await appConnection.launch();
    });

    afterEach(async () => {
        await appConnection.quit();
    });

    it('Increments using the increment button', async () => {
        const valueBefore = await appConnection.getComponentText('value-label');
        expect(valueBefore).toEqual('0');

        await appConnection.clickComponent('increment-button');

        const valueAfter = await appConnection.getComponentText('value-label');
        expect(valueAfter).toEqual('1');
    });
});
