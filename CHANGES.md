## 1.5.0

### Changes

- Use dune as a build system (#67, @Leonidas-from-XIV)
- reraise exceptions in `finish_string` instead of silencing them by raising a `Failure _`
- raise finalizer exceptions in `from_channel` and `from_lexbuf` readers

### Fixes

- Fix a race condition in builds (#57, @avsm)
