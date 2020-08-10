#!/usr/bin/env python3
"""
Mini-utility to read yaml and dump it with nice multiline strings.
Useful for formatting kubectl -o yaml.
"""
import yaml
import sys


def _str_presenter(dumper, data: str):
    """Nicer multiline presentation for yaml"""
    if len(data.splitlines()) > 1:  # check for multiline string
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    else:
        return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.add_representer(str, _str_presenter)


content = (
    sys.stdin.read()
    # need to replace \r\n with \n, otherwise pyyaml won't format as we want it
    .replace("\\r\\n", "\\n")
)

print(yaml.dump(yaml.safe_load(
    content
)))
