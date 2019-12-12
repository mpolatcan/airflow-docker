# Written by Mutlu Polatcan
# 21.10.2019

import yaml
import sys
import re


class Constants:
    KEY_CONFIG_FILES = "config_files"
    KEY_BASE_DOCKERFILE_TEMPLATE = "base_dockerfile_template"
    KEY_CONFIG_LOADER_SH_TEMPLATE = "config_loader_sh_template"
    KEY_OUTPUT_DIR = "output_dir"
    KEY_PATH = "path"
    KEY_FILENAME = "filename"
    DOCKER_ENV_VAR_FMT = "\t{env_var_name}=\"{env_var_value}\" \\"
    CONFIG_LOADER_STD_STATEMENT_FMT = "load_config \"{property}\" \"${{{env_var_name}}}\" \"{config_filename}\""
    CONFIG_LOADER_SUBST_STATEMENT_FMT = "load_config \"{property}\" \"{substitution}\" \"{config_filename}\""
    CONFIG_LOADER_OPT_SUBST_STATEMENT_FMT = "load_config_with_opt \"{property}\" \"{check}\" \"{substitution_not_null}\" \"{substitution_null}\" \"{config_filename}\""
    CONFIG_LOADER_SECTION_STATEMENT_FMT = "\nprintf \"\\n{section}\\n\" {op} \"${{AIRFLOW_CONF_DIR}}/{config_filename}\""
    CONFIGURATION_SECTION_KEY_REGEX = re.compile("<[a-z_A-Z]+>")


class BaseSetupGenerator:
    def __init__(self, config_filename):
        self.__config = yaml.safe_load(open(config_filename, "r"))

    def __get_infos(self, data, config_filename, init_section=True, property_prefix=None, env_var_prefix=None):
        init_section = init_section

        docker_env_vars, load_fn_calls = [], []

        for property, value in data.items():
            env_var_name = env_var_prefix + "_" + property if env_var_prefix else property
            property_name = property_prefix + "_" + property \
                            if property_prefix and not Constants.CONFIGURATION_SECTION_KEY_REGEX.match(property_prefix) \
                            else property
            env_var_name = env_var_name.upper().replace("<", "").replace(">", "").replace("-", "_")
            property_name = property_name[:-1] if property_name[-1] == "." else property_name

            if Constants.CONFIGURATION_SECTION_KEY_REGEX.match(property_name):
                load_fn_calls.append(
                    Constants.CONFIG_LOADER_SECTION_STATEMENT_FMT.format(
                        section=property_name.replace("<", "[").replace(">", "]"),
                        op=">" if init_section else ">>",
                        config_filename=config_filename
                    )
                )

                init_section = False

            if isinstance(value, dict):
                _docker_env_vars, _load_fn_calls = self.__get_infos(
                    value, config_filename, init_section, property_name, env_var_name
                )

                docker_env_vars.extend(_docker_env_vars)
                load_fn_calls.extend(_load_fn_calls)
            else:
                if value.find("=") == 0:  # standard load config statement
                    load_fn_calls.append(Constants.CONFIG_LOADER_SUBST_STATEMENT_FMT.format(
                        property=property_name, substitution=value[1:], config_filename=config_filename)
                    )
                elif value.find("?") == 0:  # optional load config statement
                    tokens = value.split(",")

                    load_fn_calls.append(Constants.CONFIG_LOADER_OPT_SUBST_STATEMENT_FMT.format(
                        property=property_name, check=tokens[0][1:].strip(), substitution_not_null=tokens[1].strip(), substitution_null=tokens[2].strip(), config_filename=config_filename
                    ))
                else:
                    docker_env_vars.append(Constants.DOCKER_ENV_VAR_FMT.format(env_var_name=env_var_name, env_var_value=value))
                    load_fn_calls.append(Constants.CONFIG_LOADER_STD_STATEMENT_FMT.format(property=property_name, env_var_name=env_var_name, config_filename=config_filename))

        return docker_env_vars, load_fn_calls

    def generate(self):
        docker_env_vars, load_fn_calls = [], []

        for config_info in self.__config[Constants.KEY_CONFIG_FILES]:
            config_file_path = config_info[Constants.KEY_PATH]
            config_filename = config_info[Constants.KEY_FILENAME]

            _docker_env_vars, _load_fn_calls = self.__get_infos(yaml.safe_load(open(config_file_path, "r")), config_filename)
            docker_env_vars.extend(_docker_env_vars)

            load_fn_calls.extend(_load_fn_calls)

        docker_env_vars.append(docker_env_vars.pop(len(docker_env_vars)-1).replace(" \\", ""))

        open("{loc}/Dockerfile".format(loc=self.__config[Constants.KEY_OUTPUT_DIR]), "w").write(self.__config[Constants.KEY_BASE_DOCKERFILE_TEMPLATE].format(
            env_vars="\n".join(docker_env_vars)
        ))
        open("{loc}/config_loader.sh".format(loc=self.__config[Constants.KEY_OUTPUT_DIR]), "w").write(
            self.__config[Constants.KEY_CONFIG_LOADER_SH_TEMPLATE].format(load_fn_calls="\n".join(load_fn_calls))
        )


if __name__ == "__main__":
    BaseSetupGenerator(sys.argv[1]).generate()
