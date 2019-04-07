const execSync = require('child_process').execSync;

const output = execSync('truffle migrate --network development', { encoding: 'utf-8' });  // the default is 'buffer'
if(output !== "Network up to date.\n"){
    console.log(output);
}


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