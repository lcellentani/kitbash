git init -q && git config user.email eval@example.com && git config user.name eval
printf 'int add(int a, int b) { return a + b; }\n' > math.cpp
git add math.cpp && git commit -q -m init
printf 'int add(int a, int b) { return a + b; }\nint sub(int a, int b) { return a - b; }\n' > math.cpp
git add math.cpp
