# Title 

## Abstract

TODO

## Development 

This project uses [`uv`](https://github.com/astral-sh/uv). To install:

```
curl -LsSf https://astral.sh/uv/install.sh | sh
```

The tool [`black`](https://github.com/psf/black) is used for formatting. To install with `uv`:

```
uv tool install black
```

Then, to format your changes with `black`:

```
uv run black .
```

To run with `uv`, first ensure it has installed all the packages you will need:

```
uv sync
```

Then execute a script (see below for options):

```
uv run <script>
```

## Scripts

TODO

