import * as esbuild from 'esbuild'

await esbuild.build({
  entryPoints: ['app/javascript/*.*'],
  bundle: true,
  tsconfig: 'tsconfig.json'
  sourcemap: true,
  outdir: 'app/assets/builds',
  public-path: 'assets'
})