1.4.2 (next)
------------

### Changes

- reraise exceptions in `finish_string` instead of silencing them by raising a `Failure _`
- raise finalizer exceptions in `from_channel` and `from_lexbuf` readers
