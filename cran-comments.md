# CRAN submission future.callr 0.8.2

on 2023-08-08

I've verified this submission has no negative impact on any of the 11 reverse package dependencies available on CRAN.

Thank you


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub | R-hub | mac/win-builder |
| --------- | ------ | ----- | --------------- |
| 3.4.x     | L      |       |                 |
| 4.1.x     | L      |       |                 |
| 4.2.x     | L M W  |       |                 |
| 4.3.x     | L M W  | L   W | M1 W            |
| devel     | L M W  | L     |    W            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platforms = c(
  "debian-clang-devel", 
  "debian-gcc-patched", 
  "fedora-gcc-devel",
  "windows-x86_64-release"
))
print(res)
```

gives

```
── future.callr 0.8.2: OK

  Build ID:   future.callr_0.8.2.tar.gz-396ca0f09101434389b3c2a7851cf000
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  58m 9.4s ago
  Build time: 16m 58s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.8.2: OK

  Build ID:   future.callr_0.8.2.tar.gz-26abe8dadde4400b8e33f55e69ad3fe6
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  58m 9.4s ago
  Build time: 15m 51s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.8.2: OK

  Build ID:   future.callr_0.8.2.tar.gz-1943b15e261248aa98a0351725da69e9
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  58m 9.4s ago
  Build time: 13m 31.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.8.2: OK

  Build ID:   future.callr_0.8.2.tar.gz-b005cd8ef97048d99e02318d5d630371
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  58m 9.4s ago
  Build time: 4m 36.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
