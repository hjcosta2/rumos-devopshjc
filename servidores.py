""" pip install pyyaml """

import os
import yaml

class GerenciadorServidores:
    def __init__(self, caminho_ficheiro="servidores.yaml"):
        self.caminho_ficheiro = caminho_ficheiro
        self._garantir_ficheiro_existe()

    def _garantir_ficheiro_existe(self):
        """Cria o ficheiro YAML vazio caso ele não exista."""
        if not os.path.exists(self.caminho_ficheiro):
            with open(self.caminho_ficheiro, 'w', encoding='utf-8') as f:
                yaml.dump([], f)

    def _carregar_dados(self):
        """Lê o ficheiro YAML e retorna a lista de servidores."""
        try:
            with open(self.caminho_ficheiro, 'r', encoding='utf-8') as f:
                dados = yaml.safe_load(f)
                return dados if dados is not None else []
        except Exception as e:
            print(f"Erro ao ler o ficheiro: {e}")
            return []

    def _salvar_dados(self, dados):
        """Grava a lista de servidores no ficheiro YAML."""
        try:
            with open(self.caminho_ficheiro, 'w', encoding='utf-8') as f:
                yaml.dump(dados, f, sort_keys=False, allow_unicode=True)
        except Exception as e:
            print(f"Erro ao salvar no ficheiro: {e}")

    def adicionar(self, servidor, tipo, ip):
        """Adiciona um novo servidor se o IP ou Nome já não existirem."""
        dados = self._carregar_dados()
        
        # Validação simples para evitar duplicados
        if any(s['servidor'] == servidor or s['ip'] == ip for s in dados):
            print(f"Aviso: Servidor '{servidor}' ou IP '{ip}' já existe.")
            return False
        
        novo_servidor = {
            "servidor": servidor,
            "tipo": tipo,
            "ip": ip
        }
        dados.append(novo_servidor)
        self._salvar_dados(dados)
        print(f"Servidor '{servidor}' adicionado com sucesso!")
        return True

    def listar(self):
        """Retorna e exibe todos os servidores."""
        dados = self._carregar_dados()
        if not dados:
            print("Nenhum servidor encontrado.")
        return dados

    def pesquisar(self, termo):
        """Pesquisa por servidor, tipo ou IP (busca parcial)."""
        dados = self._carregar_dados()
        resultados = [
            s for s in dados 
            if termo.lower() in s['servidor'].lower() 
            or termo.lower() in s['tipo'].lower() 
            or termo in s['ip']
        ]
        return resultados

    def remover(self, servidor_nome):
        """Remove um servidor pelo nome."""
        dados = self._carregar_dados()
        dados_filtrados = [s for s in dados if s['servidor'].lower() != servidor_nome.lower()]
        
        if len(dados) == len(dados_filtrados):
            print(f"Servidor '{servidor_nome}' não foi encontrado.")
            return False
        
        self._salvar_dados(dados_filtrados)
        print(f"Servidor '{servidor_nome}' removido com sucesso!")
        return True
