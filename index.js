
const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

q();

async function q(){
    await rl.question('Enter command:', (ans) => {
            require (`./src/${ans}.js`); 
    });
}