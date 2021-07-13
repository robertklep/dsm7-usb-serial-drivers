# HelloKernel

This package depends on Synology toolkit framework.

This package is a template package for kernel module. Users can modify this package to generate their own packages.

Please setup toolkit environment with the following [pkgscripts-ng](https://github.com/SynologyOpenSource/pkgscripts-ng).

## Build package.
After setting up the toolkit environment, you can create HelloKernel spk by the following command:
```
pkgscripts-ng/PkgCreate.py [-p {platforms}] -c HelloKernel

e.g
pkgscripts-ng/PkgCreate.py -p 6281 -c HelloKernel # will generate package for platform 6281
pkgscripts-ng/PkgCreate.py -c HelloKernel # will generate package for all platforms in build_env
```

You can find the generated spk in the result_spk directory.
