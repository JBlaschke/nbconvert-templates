# Configuration file for jupyter-nbconvert.

c = get_config()  #noqa

from pathlib import Path
# Location of this file: nbconvert-templates/setup/share
# Location of templates: nbconvert-templates/templates
# => Relative path: ../../templates
# my_templates = Path(__file__).resolve().parent.parent.joinpath("templates").absolute()
# my_templates = "/home/blaschke/Developer/nbconvert-templates/templates/"
c.TemplateExporter.extra_template_basedirs = ["{{{MY_TEMPLATES}}}"]
