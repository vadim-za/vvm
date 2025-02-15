# VVM's command line

```
vvm command filename.vvma
```
where `filename.vvma` is a path to an assembler source file. The following commands are supported:
- `run[=max_steps]` - compile and run the supplied assembler file. The `max_steps` parameter can be used to prevent the program from looping
- `dump` - compile the supplied assembler file and dump the compilation result
