# CRAN submission future.callr 0.8.0

on 2022-04-01

I've verified this submission has no negative impact on any of the 8 reverse package dependencies available on CRAN.

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version     | GitHub | R-hub    | mac/win-builder |
| ------------- | ------ | -------- | --------------- |
| 3.4.x         | L      |          |                 |
| 4.0.x         | L M    | L        |                 |
| 4.1.x         | L M W  | L M M1 W | M1              |
| 4.2.0 alpha   |        |          |    W            |
| devel         | L M W  | L        |    W            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platform = c(
  "debian-clang-devel", "debian-gcc-patched", "linux-x86_64-centos-epel",
  "macos-highsierra-release-cran", "macos-m1-bigsur-release",
  "windows-x86_64-release"))
print(res)
```

gives

```
── future.callr 0.8.0: OK

  Build ID:   future.callr_0.8.0.tar.gz-0b79af3cdff5482a990d50656bc2cb9a
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  7m 1.3s ago
  Build time: 6m 45.3s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.8.0: OK

  Build ID:   future.callr_0.8.0.tar.gz-6d8271ec08b24684959cb03f1fd35ebf
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  7m 1.3s ago
  Build time: 5m 44.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.8.0: OK

  Build ID:   future.callr_0.8.0.tar.gz-c688ab1d8ac24ac9990020e9a9133110
  Platform:   CentOS 8, stock R from EPEL
  Submitted:  7m 1.3s ago
  Build time: 4m 44.1s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.8.0: WARNING

  Build ID:   future.callr_0.8.0.tar.gz-84060ab3ad56453db18b96645d3f0fcc
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  7m 1.3s ago
  Build time: 2m 34.2s

❯ checking whether package ‘future.callr’ can be installed ... WARNING
  Found the following significant warnings:
  Warning: package 'future' was built under R version 4.1.3
  See 'C:/Users/USERMNUvhiaeqK/future.callr.Rcheck/00install.out' for details.

0 errors ✔ | 1 warning ✖ | 0 notes ✔

── future.callr 0.8.0: OK

  Build ID:   future.callr_0.8.0.tar.gz-3ab973ae8cdf4632b70553cea849fe87
  Platform:   Apple Silicon (M1), macOS 11.6 Big Sur, R-release
  Submitted:  7m 1.3s ago
  Build time: 2m 15.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.8.0: WARNING

  Build ID:   future.callr_0.8.0.tar.gz-4fdba65b735d4b34878f2f60b52a413a
  Platform:   Windows Server 2008 R2 SP1, R-release, 32/64 bit
  Submitted:  7m 1.3s ago
  Build time: 3m 32.4s

❯ checking whether package 'future.callr' can be installed ... WARNING
  Found the following significant warnings:
  Warning: package 'future' was built under R version 4.1.3
  See 'C:/Users/USERMNUvhiaeqK/future.callr.Rcheck/00install.out' for details.
```
