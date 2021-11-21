# CRAN submission future.callr 0.7.0

on 2021-11-20

I've verified this submission has no negative impact on any of the seven reverse dependencies on CRAN.

Thank you


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version     | GitHub | R-hub      | mac/win-builder |
| ------------- | ------ | ---------- | --------------- |
| 3.3.x         | L      |            |                 |
| 3.4.x         | L      |            |                 |
| 3.5.x         | L      |            |                 |
| 4.0.x         | L      | L          |                 |
| 4.1.x         | L M W  | L M M1 S W | M1 W            |
| devel         | L M W  | L          |    W            |

*Legend: OS: L = Linux, S = Solaris, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platform = c(
  "debian-clang-devel", "debian-gcc-patched", "linux-x86_64-centos-epel",
  "solaris-x86-patched-ods",
  "macos-highsierra-release-cran", "macos-m1-bigsur-release",
  "windows-x86_64-release"))
print(res)
```

gives:


```
── future.callr 0.7.0: OK

  Build ID:   future.callr_0.7.0.tar.gz-02f963db9567439d8acfd944116b530a
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  17m 34.4s ago
  Build time: 4m 40.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.7.0: OK

  Build ID:   future.callr_0.7.0.tar.gz-e83a6b869a53435e844b1ea7236c72df
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  17m 34.4s ago
  Build time: 3m 46s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.7.0: OK

  Build ID:   future.callr_0.7.0.tar.gz-807706a6e0b34a1eb3fd6c8467a9c804
  Platform:   CentOS 8, stock R from EPEL
  Submitted:  17m 34.4s ago
  Build time: 3m 2.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.7.0: OK

  Build ID:   future.callr_0.7.0.tar.gz-285d7bad39714e929fe697e81e35eff3
  Platform:   Oracle Solaris 10, x86, 32 bit, R release, Oracle Developer Studio 12.6
  Submitted:  17m 34.4s ago
  Build time: 4m 6.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.7.0: OK

  Build ID:   future.callr_0.7.0.tar.gz-4df5985a7f7f4899a61bdee68ad84b5b
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  17m 34.4s ago
  Build time: 5m 31.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.7.0: OK

  Build ID:   future.callr_0.7.0.tar.gz-8811d5bbe07d461eba6e003ef8d3dfca
  Platform:   Apple Silicon (M1), macOS 11.6 Big Sur, R-release
  Submitted:  17m 34.4s ago
  Build time: 1m 20s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.callr 0.7.0: OK

  Build ID:   future.callr_0.7.0.tar.gz-ad66d2b008924a498c4d8b4f53a576b7
  Platform:   Windows Server 2008 R2 SP1, R-release, 32/64 bit
  Submitted:  17m 34.4s ago
  Build time: 3m 48s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```