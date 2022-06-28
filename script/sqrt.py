height = 230
N = 13
base_length = height / 8

def next_vertex(x, y):
    h = (x**2 + y**2)**0.5
    return (x - y/h, y + x/h)

# Code for the sqrt svg
prelude = f'<svg height="{height}" width="{height}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">\n'
out = f'<rect width="{height}" height="{height}" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" />'
print(f"        if (level == 0)\n            return '{out}';")

# Origin
o_x, o_y = 0, 0
b_x, b_y = 1, 0

# Center
c_x, c_y = (height / 2), (height / 2)

for i in range(0, N):
    n_x, n_y = next_vertex(b_x, b_y)
    p1_x = c_x + o_x
    p1_y = c_y + o_y
    p2_x = c_x + base_length * b_x
    p2_y = c_y + base_length * b_y
    p3_x = c_x + base_length * n_x
    p3_y = c_y + base_length * n_y
    out += f'<polygon points="{round(p1_x)},{round(p1_y)} {round(p2_x)},{round(p2_y)} {round(p3_x)},{round(p3_y)}" fill="none" stroke="white">'
    out += f'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 {round(p1_x)} {round(p1_y)}" to="360 {round(p1_x)} {round(p1_y)}" dur="10s" repeatCount="indefinite"/></polygon>'

    b_x, b_y = n_x, n_y
    if i != N - 1:
        print(f"        if (level == {i + 1})\n            return '{out}';")
    else:
        print(f"        else\n            return '{out}';")

svg = prelude + out + '\n</svg>\n'

with open("sqrt.svg", 'w') as f:
    f.write(svg)

