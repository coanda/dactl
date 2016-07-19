#!/usr/bin/env python

from jinja2 import Environment, PackageLoader

env = Environment(loader=PackageLoader('test', '.'))

plugin = {}
plugin['id'] = 'plug0'
plugin['type'] = 'plugin'
plugin['uc_type'] = 'Plugin'
plugin['name'] = 'test'
plugin['hyph_name'] = 'test'
plugin['namespace'] = 'ui'

template = env.get_template('common/README.md.jnj')
print template.render(plugin=plugin)
