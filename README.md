## Create new project
## Teste de CODEOWNERS


Click:

Use this template

Then:

git clone <new-repo>

Build:

conan install . --output-folder=build --build=missing
cmake -B build
cmake --build build