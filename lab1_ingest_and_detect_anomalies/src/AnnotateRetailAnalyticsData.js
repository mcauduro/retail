const ABOVE_FREEZING_WEATHER = ['sunny', 'rainy', 'cloudy'];
const BELOW_FREEZING_WEATHER = ['snowy', 'cloudy', 'sunny'];

exports.handler = async (event, context) => {
    // Process records and annotate them with current weather and temperature
    let annotatedRecords = event.records.map((record) => {
        let payload = JSON.parse(Buffer.from(record.data, 'base64').toString());

        // mock up the weather
        payload.temperature = getRandom(25, 75);
        payload.weather = (payload.temperature < 32) ? BELOW_FREEZING_WEATHER[getRandom(0, 2)] : ABOVE_FREEZING_WEATHER[getRandom(0, 2)];

        let annotatedRecord = `${JSON.stringify(payload)}\n`;
        //console.log(`Annotated record:\n ${annotatedRecord}`);

        return {
            recordId: record.recordId,
            result: 'Ok',
            data: Buffer.from(annotatedRecord).toString('base64')
        };
    });

    console.log(`Annotated ${annotatedRecords.length} records with weather and temperature.`);
    return { records: annotatedRecords };
};

// Random number within a range (inclusive)
function getRandom(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
