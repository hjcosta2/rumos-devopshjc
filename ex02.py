import yaml

def adicionar_entrada_yaml(caminho_ficheiro, chave, valor):
    """
    Lê um ficheiro YAML, adiciona ou atualiza uma entrada e grava o ficheiro.
    """
    try:
        # 1. Ler o ficheiro YAML existente
        with open(caminho_ficheiro, 'r', encoding='utf-8') as ficheiro:
            dados = yaml.safe_load(ficheiro) or {}
        
        # 2. Adicionar a nova entrada usando os parâmetros recebidos
        dados[chave] = valor
        
        # 3. Guardar as alterações de volta no ficheiro
        with open(caminho_ficheiro, 'w', encoding='utf-8') as ficheiro:
            yaml.safe_dump(dados, ficheiro, default_flow_style=False, allow_unicode=True, sort_keys=False)
            
        print(f"Sucesso: Chave '{chave}' adicionada/atualizada com sucesso em '{caminho_ficheiro}'.")
        
    except FileNotFoundError:
        print(f"Erro: O ficheiro '{caminho_ficheiro}' não foi encontrado.")
    except yaml.YAMLError as exc:
        print(f"Erro ao processar o ficheiro YAML: {exc}")

# --- Exemplos de Uso ---
if __name__ == "__main__":
    nome_do_ficheiro = 'config.yaml'
    
    # Exemplo 1: Adicionar um texto simples
    adicionar_entrada_yaml(nome_do_ficheiro, 'ambiente', 'producao')
    
    # Exemplo 2: Adicionar um número
    adicionar_entrada_yaml(nome_do_ficheiro, 'timeout_segundos', 30)
    
    # Exemplo 3: Adicionar uma lista (Array)
    adicionar_entrada_yaml(nome_do_ficheiro, 'administradores', ['Ana', 'Pedro', 'Nuno'])
    
    # Exemplo 4: Adicionar um dicionário (Objeto aninhado)
    dados_api = {'url': 'https://api.exemplo.com', 'chave_api': '12345xyz'}
    adicionar_entrada_yaml(nome_do_ficheiro, 'servicos_externos', dados_api)
