# -*- coding: utf-8 -*-

########################################################################################################
# 测试主文件：语料文本语言编码转码与内容数据初步清洗 - 作者：i126@126.com
########################################################################################################

# from sc.utils import toutf8, filter

# from sc.utils import txtFilter


from sc.test1 import c1
from sc.utils import txtFilter

#  init project reqs 
# pip install pipreqs
# pipreqs --encoding=utf8
# pip install -r requirements.txt
path = "C:\\Dev\\语料\\01先秦"

print('\n')
print('run.py hello')

if __name__ == '__main__':
    print("main")
    c1.f1()
    # filter.delUnrelatedFile(path)
    txtFilter.recodeTxt(path)



    
# # 程序入口
# if __name__ == '__main__':
    # 入口：

    # 整体转换一个目录（含子目录）下所有文本文件
    # toutf8.allpath(inputpath,file_ext)

    # 整体转换一个目录下（不含子目录）所有文本文件
    # toutf8.path(inputpath, file_ext)

    # 单独转换一个文本文件
    # toutf8.file(inputfile, file_ext)

    # 单独过滤一个文本文件
    # filter.file(inputfile, outpath, file_ext)

    # 整体转换并过滤一个目录（含子目录）下所有文本文件。转换过滤后的文件统一放入一个outpath目录。不覆盖原文本文件。
    # 备注：filter.allpath的最后一个参数 flag 如果不填写，则表示不进行简繁体转换。flag有两个选项：繁体转简体 zh2cn、简体转繁体 zh2tw
    #      强制繁体转简体 举例：filter.allpath(inputpath, outpath, file_ext, 'zh2cn')
    # filter.allpath(inputpath, outpath, file_ext)

    # filter.recodeTxt('/Users/zhanxuzhao/Dev/text2text/input')
    # print('main')
    # path = "C:\\Dev\\语料"
    # # filter.delUnrelatedFile(path)
    # # txtFilter.recodeTxt(path)
    # test1.log()