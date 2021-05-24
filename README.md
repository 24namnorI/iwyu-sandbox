# iwyu-sandbox

This is just a little sandbox to try to understand some flaws in iwyu. I'm working on _Debian Buster_ with `include-what-you-use` `0.11` based on `clang` version `7.0.1-3`.

I noticed that applying the iwyu changes would result in broken code. In this small example it was a missing `<sstream>` include. This is now fixed with an `imp` file.

All the logic is kind of captured in the makefile.