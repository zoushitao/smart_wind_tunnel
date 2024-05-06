import xlrd
import os

current_directory = os.getcwd()
print("当前工作目录：", current_directory)
# 打开 Excel 文件
workbook = xlrd.open_workbook('background.xls')

# 获取第一个工作表
worksheet = workbook.sheet_by_index(0)

# 定义要读取的行数和列数
num_rows = 40
num_cols = 40

# 读取数据并存储为二维数组
data = []
for row_index in range(num_rows):
    row_data = []
    for col_index in range(num_cols):
        cell_value = worksheet.cell_value(row_index, col_index)
        list_item = 0;
        if(cell_value==1.0):
            list_item = 1
        else:
            list_item = 0
        row_data.append(list_item)
    data.append(row_data)






##转化为c字符串
def convert_to_c_style_array(arr):
    rows = len(arr)
    cols = len(arr[0])

    c_style_array = "{\n"
    for i in range(rows):
        c_style_array += "    {"
        for j in range(cols):
            element = str(arr[i][j])
            c_style_array += element
            if j != cols - 1:
                c_style_array += ", "
        c_style_array += "}"
        if i != rows - 1:
            c_style_array += ","
        c_style_array += "\n"
    c_style_array += "};"

    return c_style_array   

# 转换为 C 语言风格的数组字符串
c_style_array = convert_to_c_style_array(data)

# 输出 C 语言风格的数组字符串
head = "int background[40][40]="
print(c_style_array)


text = head+c_style_array

# 打开文件，以写入模式创建或覆盖文件
with open("background.h", "w") as file:
    # 将字符串写入文件
    file.write(text)

print("字符串已成功写入文件。")