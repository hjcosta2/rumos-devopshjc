# Define a variável com o nome/caminho do ficheiro YAML que vai guardar os dados
$CaminhoFicheiro = "servidores.yaml"

# Importa o módulo externo para o PowerShell conseguir processar a sintaxe YAML
Import-Module powershell-yaml

# Declaração da função responsável por garantir que o ficheiro de base de dados existe
function Garantir-FicheiroExiste {
    # Verifica se o ficheiro NÃO existe no caminho especificado
    if (-not (Test-Path $CaminhoFicheiro)) {
        # Cria um texto com a estrutura de um array vazio em YAML e grava-o no ficheiro com encoding UTF-8
        "[]" | Out-File $CaminhoFicheiro -Encoding utf8
    }
}

# Declaração da função que lê e traduz o ficheiro YAML para objetos PowerShell
function Carregar-Dados {
    # Chama a função de validação para garantir que o ficheiro existe antes de o tentar ler
    Garantir-FicheiroExiste
    # Lê todo o conteúdo do ficheiro de texto de uma só vez (parâmetro -Raw) e guarda na variável
    $Conteudo = Get-Content $CaminhoFicheiro -Raw
    # Utiliza o módulo importado para transformar o texto YAML num objeto nativo manipulável
    $Dados = Get-YamlObject -Yaml $Conteudo
    
    # Se o ficheiro estivesse vazio ou inválido, a variável seria nula
    if ($null -eq $Dados) { 
        # Retorna um array vazio para evitar erros nas funções seguintes
        return @() 
    }
    # Retorna os dados colocando uma vírgula antes para forçar o PowerShell a manter a estrutura de Array
    return ,$Dados
}

# Declaração da função que transforma objetos PowerShell em texto YAML e os guarda
function Salvar-Dados ($Dados) {
    # Converte o objeto ou array do PowerShell de volta para uma string formatada em YAML
    $YamlTexto = Out-Yaml -InputObject $Dados
    # Pega na string gerada e escreve-a no ficheiro físico, aplicando a codificação UTF-8
    $YamlTexto | Out-File $CaminhoFicheiro -Encoding utf8
}

# Declaração da função para inserir um novo servidor, recebendo 3 parâmetros obrigatórios
function Adicionar-Servidor ($Servidor, $Tipo, $Ip) {
    # Carrega a lista atual de servidores existentes no ficheiro
    $Dados = Carregar-Dados
    
    # Filtra os dados à procura de algum registo onde o nome seja igual ao fornecido OU o IP seja igual
    $Existe = $Dados | Where-Object { $_.servidor -eq $Servidor -or $_.ip -eq $Ip }
    # Se a variável de validação não estiver vazia, significa que já existe um duplicado
    if ($null -ne $Existe) {
        # Exibe um aviso amarelo no terminal a informar o utilizador sobre o duplicado
        Write-Warning "O Servidor '$Servidor' ou o IP '$Ip' já existe no inventário."
        # Interrompe a função e retorna 'falso' indicando que não foi adicionado
        return $false
    }
    
    # Cria uma estrutura de dicionário nativa do PowerShell (PSCustomObject) com as propriedades pedidas
    $NovoServidor = [PSCustomObject]@{
        servidor = $Servidor # Atribui o parâmetro do nome do servidor à chave 'servidor'
        tipo     = $Tipo     # Atribui o parâmetro do ambiente/tipo à chave 'tipo'
        ip       = $Ip       # Atribui o parâmetro do endereço IP à chave 'ip'
    }
    
    # Adiciona o novo objeto personalizado ao final do array de dados existente
    $Dados += $NovoServidor
    # Grava a lista atualizada de volta no ficheiro YAML
    Salvar-Dados $Dados
    # Exibe uma mensagem de sucesso no terminal com a cor verde
    Write-Host "Servidor '$Servidor' adicionado com sucesso!" -ForegroundColor Green
    # Retorna 'verdadeiro' para indicar que a operação foi concluída com sucesso
    return $true
}

# Declaração da função que lista todos os servidores formatados no ecrã
function Listar-Servidores {
    # Carrega a lista de servidores extraída do ficheiro YAML
    $Dados = Carregar-Dados
    # Se o contador de itens no array for igual a zero, o inventário está vazio
    if ($Dados.Count -eq 0) {
        # Exibe uma mensagem em amarelo a avisar que não há registos
        Write-Host "Nenhum servidor encontrado." -ForegroundColor Yellow
        # Sai da função mais cedo já que não há nada para listar
        return
    }
    # Envia os dados para o formatador de tabelas do PowerShell ajustando a largura das colunas automaticamente
    $Dados | Format-Table -AutoSize
}

# Declaração da função para pesquisar termos dentro do inventário
function Pesquisar-Servidor ($Termo) {
    # Obtém a lista atual de servidores
    $Dados = Carregar-Dados
    # Filtra a lista verificando se o termo pesquisado está contido em qualquer um dos três campos (utilizando wildcards *)
    $Resultados = $Dados | Where-Object { 
        $_.servidor -like "*$Termo*" -or # Procura correspondência parcial no nome
        $_.tipo -like "*$Termo*" -or     # Procura correspondência parcial no tipo
        $_.ip -like "*$Termo*"           # Procura correspondência parcial no IP
    }
    # Retorna o array de resultados (pode conter 0, 1 ou mais servidores encontrados)
    return ,$Resultados
}

# Declaração da função que remove um servidor com base no nome exato
function Remover-Servidor ($ServidorNome) {
    # Puxa o inventário atualizado do ficheiro
    $Dados = Carregar-Dados
    
    # Cria uma nova lista contendo apenas os servidores cujo nome seja DIFERENTE (-ne) do nome indicado
    $DadosFiltrados = $Dados | Where-Object { $_.servidor -ne $ServidorNome }
    
    # Se o tamanho da lista original for igual ao da lista filtrada, nenhum registo foi removido
    if ($Dados.Count -eq $DadosFiltrados.Count) {
        # Mostra um aviso a dizer que o alvo não foi encontrado no ficheiro
        Write-Warning "Servidor '$ServidorNome' não foi encontrado."
        # Termina a função retornando falso
        return $false
    }
    
    # Guarda a nova lista filtrada (sem o servidor apagado) no ficheiro YAML
    Salvar-Dados $DadosFiltrados
    # Informa o utilizador no terminal com texto verde que o servidor foi removido
    Write-Host "Servidor '$ServidorNome' removido com sucesso!" -ForegroundColor Green
    # Retorna verdadeiro comprovando a exclusão
    return $true
}
