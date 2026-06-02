import os
import unittest
from servidores import GerenciadorServidores  # Assume que guardaste a classe num ficheiro chamado gerenciador.py

class TestGerenciadorServidores(unittest.TestCase):
    
    def setUp(self):
        """Executado antes de CADA teste. Cria um ficheiro temporário de testes."""
        self.ficheiro_teste = "servidores_teste.yaml"
        self.gestor = GerenciadorServidores(self.ficheiro_teste)

    def tearDown(self):
        """Executado após CADA teste. Limpa o ficheiro temporário."""
        if os.path.exists(self.ficheiro_teste):
            os.remove(self.ficheiro_teste)

    def test_adicionar_servidor_com_sucesso(self):
        """Testa se um servidor é adicionado corretamente."""
        resultado = self.gestor.adicionar("srv-teste-01", "Desenvolvimento", "10.0.0.1")
        self.assertTrue(resultado)
        
        # Verifica se foi mesmo guardado
        dados = self.gestor.listar()
        self.assertEqual(len(dados), 1)
        self.assertEqual(dados[0]["servidor"], "srv-teste-01")

    def test_evitar_duplicados(self):
        """Testa se o sistema bloqueia a adição de nomes ou IPs duplicados."""
        self.gestor.adicionar("srv-unico", "Web", "10.0.0.2")
        
        # Tenta adicionar com o mesmo nome
        resultado_nome_duplicado = self.gestor.adicionar("srv-unico", "Outro", "10.0.0.3")
        # Tenta adicionar com o mesmo IP
        resultado_ip_duplicado = self.gestor.adicionar("srv-diferente", "Web", "10.0.0.2")
        
        self.assertFalse(resultado_nome_duplicado)
        self.assertFalse(resultado_ip_duplicado)
        self.assertEqual(len(self.gestor.listar()), 1)

    def test_listar_ficheiro_vazio(self):
        """Testa o comportamento de listagem quando não há servidores."""
        dados = self.gestor.listar()
        self.assertEqual(dados, [])

    def test_pesquisar_servidores(self):
        """Testa a pesquisa por correspondência parcial (case-insensitive)."""
        self.gestor.adicionar("srv-prod-web", "Produção", "192.168.1.10")
        self.gestor.adicionar("srv-dev-db", "Base de Dados", "192.168.1.20")
        
        # Pesquisa por parte do nome
        busca_nome = self.gestor.pesquisar("prod")
        self.assertEqual(len(busca_nome), 1)
        self.assertEqual(busca_nome[0]["servidor"], "srv-prod-web")
        
        # Pesquisa por tipo
        busca_tipo = self.gestor.pesquisar("Dados")
        self.assertEqual(len(busca_tipo), 1)
        
        # Pesquisa por IP
        busca_ip = self.gestor.pesquisar("192.168.1.")
        self.assertEqual(len(busca_ip), 2)

    def test_remover_servidor_existente(self):
        """Testa a remoção com sucesso de um servidor."""
        self.gestor.adicionar("srv-deletar", "Temporário", "10.0.0.5")
        
        resultado = self.gestor.remover("srv-deletar")
        self.assertTrue(resultado)
        self.assertEqual(len(self.gestor.listar()), 0)

    def test_remover_servidor_inexistente(self):
        """Testa a tentativa de remover um servidor que não existe."""
        self.gestor.adicionar("srv-real", "Produção", "10.0.0.6")
        
        resultado = self.gestor.remover("srv-fantasma")
        self.assertFalse(resultado)
        self.assertEqual(len(self.gestor.listar()), 1)

if __name__ == "__main__":
    unittest.main()
