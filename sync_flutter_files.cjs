const fs = require('fs');
const path = require('path');

function getCategory(filePath) {
  if (filePath === 'pubspec.yaml') return 'Config';
  if (filePath === 'test/widget_test.dart') return 'Test';
  if (filePath === 'lib/main.dart') return 'Entrée';
  if (filePath === 'lib/app.dart') return 'Entrée';
  if (filePath.startsWith('lib/core/')) return 'Core';
  if (filePath.startsWith('lib/navigation/')) return 'Navigation';
  if (filePath.startsWith('lib/providers/')) return 'Providers';
  if (filePath.startsWith('lib/screens/')) return 'Screens';
  return 'Config';
}

function walkDir(dir, fileList = []) {
  if (!fs.existsSync(dir)) return fileList;
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    if (stat.isDirectory()) {
      walkDir(filePath, fileList);
    } else {
      fileList.push(filePath);
    }
  }
  return fileList;
}

const allFiles = [];
if (fs.existsSync('pubspec.yaml')) {
  allFiles.push('pubspec.yaml');
}
const libFiles = walkDir('lib');
allFiles.push(...libFiles);
if (fs.existsSync('test/widget_test.dart')) {
  allFiles.push('test/widget_test.dart');
}

const flutterFiles = [];
for (const file of allFiles) {
  if (!fs.existsSync(file)) continue;
  const content = fs.readFileSync(file, 'utf8');
  const relativePath = file.replace(/\\/g, '/');
  const name = path.basename(file);
  const category = getCategory(relativePath);
  
  flutterFiles.push({
    path: relativePath,
    name: name,
    category: category,
    code: content
  });
}

let output = `export interface FlutterFile {
  path: string;
  name: string;
  category: string;
  code: string;
}

export const FLUTTER_FILES: FlutterFile[] = [
`;

for (const f of flutterFiles) {
  output += `  {
    path: ${JSON.stringify(f.path)},
    name: ${JSON.stringify(f.name)},
    category: ${JSON.stringify(f.category)},
    code: \`${f.code.replace(/\\/g, '\\\\').replace(/`/g, '\\`').replace(/\${/g, '\\${')}\`
  },\n`;
}

output += `];\n`;

fs.writeFileSync('src/data/flutter_files.ts', output, 'utf8');
console.log('Successfully synchronized Flutter files to src/data/flutter_files.ts!');
