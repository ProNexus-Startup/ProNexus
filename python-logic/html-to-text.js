const { htmlToText } = require('html-to-text');

// Read HTML input from the first command line argument
const htmlInput = process.argv[2];

const text = htmlToText(htmlInput, {
    wordwrap: 130
});

console.log(text);
