import re
import sys


def match_(raw_temp_str):
    pattern = re.compile(r'\$\{[a-z|A-Z|0-9]+(_[a-z|A-Z|0-9]+)*\}')
    matchedList = pattern.finditer(raw_temp_str)
    result = []

    for item in matchedList:
        result.append(item.group())

    # print("match_ result:", result)

    return result


def replace_(raw_temp_str, profile):
    for matched in match_(raw_temp_str):
        print("matched:", matched)
        env_name = matched.replace('${', '')
        env_name = env_name.replace('}', '')
        replacement = ""
        if env_name in profile.keys():
            replacement = profile[env_name]
        raw_temp_str = raw_temp_str.replace(matched, replacement)
    return raw_temp_str


def replace_yaml_temp(yaml_file, new_yaml_file, env_file):
    try:
        profile = prop_value(env_file)

        with open(yaml_file, 'r+') as yml_file, open(new_yaml_file, 'w') as yml_output:

            yml_file_lines = yml_file.readlines()

            for line in yml_file_lines:
                new_line = line
                new_line = replace_(new_line, profile)
                yml_output.write(new_line)

    except IOError as e:
        print("Error: " + format(str(e)))
        raise

# TODO: 考虑增加参数默认值支持. 考虑增加注释符号过滤 .
def prop_value(env_file):
    profileList = {}
    with open(env_file) as profile:
        new_profile = profile.readlines()
        for line in new_profile:
            line_key = line.strip().split("=", 1)[0]
            profileList[line_key] = line.strip().split("=", 1)[1]

    print("profileList:", profileList)

    return profileList


if __name__ == '__main__':
    print(sys.argv)
    if len(sys.argv) < 2:
        print("param invalid")
    elif len(sys.argv) >= 3:
        command = sys.argv[1]
        temp_file = sys.argv[2]
        out_file = sys.argv[3]
        env = sys.argv[4]
        if command == 'replace':
            replace_yaml_temp(temp_file, out_file, env)
