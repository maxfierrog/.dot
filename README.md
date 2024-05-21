# Dot Files

The setup here is such that these never need to be moved from the directory they are cloned into. The script `unpack.sh` creates soft links to its contents in an input directory. First clone recursively:

```
git clone --recursive
```

Then, to create soft links in root directory on a Mac:

```
./unpack.sh content ~/
```

This keeps things neat.

