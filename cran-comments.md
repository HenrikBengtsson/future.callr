# CRAN submission future.callr 0.8.1

on 2022-12-13

I've verified this submission has no negative impact on any of the 9 reverse package dependencies available on CRAN.

Thank you


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub | R-hub  | mac/win-builder |
| --------- | ------ | ------ | --------------- |
| 3.4.x     | L      |        |                 |
| 3.6.x     | L      |        |                 |
| 4.0.x     | L      |        |                 |
| 4.1.x     | L M W  |   M    |                 |
| 4.2.x     | L M W  | L   W  | M1 W            |
| devel     | L M W  | L      | M1 W            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platforms = c(
  "debian-clang-devel", 
  "debian-gcc-patched", 
  "fedora-gcc-devel",
  "macos-highsierra-release-cran",
  "windows-x86_64-release"
))
print(res)
```

gives

```
── future.callr 0.8.1: OK

  Build ID:   future.callr_0.8.1.tar.gz-dd9c44c07f1e4cbdbb0d2622e33e40e7
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  28m 18.4s ago
  Build time: 28m 11.1s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.8.1: OK

  Build ID:   future.callr_0.8.1.tar.gz-735855501ba64658986f26d86fdc656b
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  28m 18.5s ago
  Build time: 25m 44.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.8.1: OK

  Build ID:   future.callr_0.8.1.tar.gz-766d6c03b3fd428782308da41a4fd56d
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  28m 18.5s ago
  Build time: 17m 45s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.8.1: WARNING

  Build ID:   future.callr_0.8.1.tar.gz-77ecce449c554f8784ef7f0984874d44
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  28m 18.5s ago
  Build time: 3m 53.2s

❯ checking whether package ‘future.callr’ can be installed ... WARNING
  Found the following significant warnings:
  Warning: package ‘future’ was built under R version 4.1.2

0 errors ✔ | 1 warning ✖ | 0 notes ✔

── future.callr 0.8.1: OK

  Build ID:   future.callr_0.8.1.tar.gz-28b347cb1e30480697adeeecf9865299
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  28m 18.5s ago
  Build time: 3m 7.7s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
