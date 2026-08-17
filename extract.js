const fs = require('fs');
const html = fs.readFileSync('d:\\ihateb\\profile_vladandrei.html', 'utf8');
const titleMatch = html.match(/<title>(.*?)<\/title>/i);
console.log('Title:', titleMatch ? titleMatch[1] : 'Not Found');
const rankMatch = html.match(/Clasament\s*global.*?#(\d+)/i) || html.match(/#(\d+)/);
console.log('Rank:', rankMatch ? rankMatch[1] : 'Not found');
