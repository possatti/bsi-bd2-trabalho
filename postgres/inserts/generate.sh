#!/bin/sh

# Junta todos os arquivos de insert num arquivo só.
cat \
./cliente.sql \
./endereco.sql \
./motorista.sql \
./veiculo.sql \
./pedido.sql \
./viagem.sql \
./carga.sql \
./motorista_veiculo.sql \
 > ../preencher-tabelas.sql
