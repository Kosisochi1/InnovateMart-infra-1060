exports.handler = async (event) => {
  for (const record of event.Records) {
    const fileName = record.s3.object.key;
    console.log(`Image received: ${fileName}`);
  }

  return {
    statusCode: 200,
  };
};
