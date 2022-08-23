Getting Started with Move
==============

https://github.com/move-language/move/tree/main/language/tools/move-cli
# build
```
move build
```

# view bytecode
```
move disassemble --name HelloWorld
move disassemble --name Test
```

# publish
```
move sandbox publish -v
```
to view published module
```
move sandbox view storage/0x00000000000000000000000000000002/modules/Test.mv
```
to clean,
```
move sandbox clean
```
# run
```
move sandbox run scripts/test.move --signers 0xf -v --dry-run
move sandbox run scripts/test.move --signers 0xf -v
```
# test
```
UPDATE_BASELINE=1 move sandbox exp-test
```