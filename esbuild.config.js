const path = require('path');

require("esbuild").build({
  entryPoints: ["app/javascript/*.*"],
  bundle: true,
  outdir: path.join(process.cwd(), "app/assets/builds"),
  absWorkingDir: path.join(process.cwd(), "app/javascript"),
  publicPath: "assets",
  sourcemap: true,
  watch: process.argv.includes('--watch'),
  plugins: [],
  loader: {
    '.js': 'jsx',
    '.jpg': 'file',
    '.png': 'file',
    '.MOV': 'file'
  },
}).catch(() => process.exit(1));
I