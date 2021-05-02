module hangxie/parquet-tools

go 1.16

require (
	github.com/alecthomas/kong v0.2.16
	github.com/hangxie/parquet-tools/cmd v0.0.0-00010101000000-000000000000
	github.com/pkg/errors v0.9.1 // indirect
	github.com/stretchr/testify v1.5.1 // indirect
	gopkg.in/yaml.v2 v2.2.8 // indirect
)

replace github.com/hangxie/parquet-tools/cmd => ./cmd