# Configuration file for jupyter-nbconvert.

c = get_config()  #noqa

from pathlib import Path
c.TemplateExporter.extra_template_basedirs = ["{{{MY_TEMPLATES}}}"]
