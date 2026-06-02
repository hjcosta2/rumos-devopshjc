# repo25052026
## Parte 1
bla
## Parte 2
bls
success()	É o comportamento padrão. O job só corre se todos os jobs listados em needs terminarem com sucesso.
failure()	O job corre apenas se qualquer um dos jobs em needs falhar (excelente para alertas).
always()	Força o job a correr, independentemente do estado dos jobs anteriores (útil para limpezas de ambiente).
cancelled()	Corre apenas se o workflow tiver sido cancelado manualmente ou por timeout.
