pragma solidity ^0.4.11;

/// @title Catalogo de Ouvidorias para o Barramento de Ouvidorias
/*
    Cada ouvidoria somente pode autorizar uma vez.
*/
contract CatalogoOuvidorias {

    uint constant NUMERO_DE_AUTORIZACOES_EXIGIDAS_PARA_UMA_NOVA_OUVIDORIA_PODER_CADASTRARSE = 3;

    enum TipoEnte { Uniao, Estado, Municipio }

    struct Ente {
        TipoEnte tipo;
        bytes32 nome;   // nome do ente, caso se aplique (Uniao nao eh necessario). Ex.: 'Bahia', 'Salvador-BA'
    }

    struct Ouvidoria {
        address conta; // account Ethereum desta ouvidoria
        bytes32 nome;   // nome do orgao
        Ente ente; // ente a qual a ouvidoria pertence
        bytes32 endpoint;   // URL da aplicacao/web service desta ouvidoria

        // variavel de controle pq o solidity eh peh duro e nao fornece maneiras de testar se uma chave existe no map
        // https://ethereum.stackexchange.com/a/13029
        // https://ethereum.meta.stackexchange.com/questions/443/blog-simple-storage-patterns-in-solidity
        bool existe;
    }

    address[] contasOuvidorias;

    mapping(address => Ouvidoria) private ouvidorias;

    mapping(address => address[]) public ouvidoriasCandidatasComAutorizacoes;

    event ouvidoriaCadastrada(address conta, bytes32 nome, uint8 tipoEnte, bytes32 nomeEnte, bytes32 endpoint);

    event ouvidoriaAutorizada(address ouvidoriaAutorizadora, address ouvidoriaCandidata);

    /// Cria o catalogo com uma ouvidoria -- nao exigi tres porque seriam tantas variaveis que o solarity nao permite:
    /// Compiler error (...): Stack too deep, try removing local variables.
    function CatalogoOuvidorias(bytes32 nome, uint8 tipoEnte, bytes32 nomeEnte, bytes32 endpoint) {
        inserirOuvidoriaNoCadastro(msg.sender, nome, tipoEnte, nomeEnte, endpoint);
    }

    function inserirOuvidoriaNoCadastro(address conta, bytes32 nome, uint8 tipoEnte, bytes32 nomeEnte, bytes32 endpoint) private {
        ouvidorias[conta] = Ouvidoria({
            conta: conta,
            nome: nome,
            ente: Ente({tipo: toTipoEnte(tipoEnte), nome: nomeEnte}),
            endpoint: endpoint,
            existe: true
        });
        contasOuvidorias.push(conta);
    }

    function toTipoEnte(uint8 tipo) constant returns (TipoEnte) {
        if (tipo == 0) return TipoEnte.Uniao;
        if (tipo == 1) return TipoEnte.Estado;
        if (tipo == 2) return TipoEnte.Municipio;
        throw;
    }

    function getNumeroDeOuvidorias() constant returns (uint) {
        return contasOuvidorias.length;
    }

    function getContaOuvidoria(uint indiceDaOuvidoriaNoArray) constant returns (address) {
        return contasOuvidorias[indiceDaOuvidoriaNoArray];
    }

    function getOuvidoriaNome(address contaOuvidoria) constant returns (string) {
        return toString(ouvidorias[contaOuvidoria].nome);
    }

    function getOuvidoriaEndpoint(address contaOuvidoria) constant returns (string) {
        return toString(ouvidorias[contaOuvidoria].endpoint);
    }

    function getOuvidoriaEnteTipo(address contaOuvidoria) constant returns (uint) {
        return uint(ouvidorias[contaOuvidoria].ente.tipo);
    }

    function getOuvidoriaEnteNome(address contaOuvidoria) constant returns (string) {
        return toString(ouvidorias[contaOuvidoria].ente.nome);
    }

    /// Uma ouvidoria cadastrada pode autorizar outra que ainda nao se cadastrou
    function autorizar(address contaOuvidoriaCandidata) {
        require(
            isOuvidoriaCadastrada(msg.sender) &&
            !isOuvidoriaCadastrada(contaOuvidoriaCandidata) &&
            autorizadoraNuncaAutorizouCandidata(msg.sender, contaOuvidoriaCandidata)
        );
        ouvidoriasCandidatasComAutorizacoes[contaOuvidoriaCandidata].push(msg.sender);

        ouvidoriaAutorizada(msg.sender, contaOuvidoriaCandidata);
    }

    function isOuvidoriaCadastrada(address contaOuvidoria) constant returns (bool) {
        return ouvidorias[contaOuvidoria].existe;
    }

    function autorizadoraNuncaAutorizouCandidata(address contaOuvidoriaAutorizadora, address contaOuvidoriaCandidata) constant returns (bool) {
        var quemJahAutorizouEstaCandidata = ouvidoriasCandidatasComAutorizacoes[contaOuvidoriaCandidata];
        for (uint i = 0; i < quemJahAutorizouEstaCandidata.length; i++) {
            if (quemJahAutorizouEstaCandidata[i] == contaOuvidoriaAutorizadora) {
                return false;
            }
        }
        return true;
    }

    /// Uma ouvidoria que recebeu autorizacoes suficientes pode cadastrar-se
    function cadastrar(bytes32 nome, uint8 tipoEnte, bytes32 nomeEnte, bytes32 endpoint) {
        require(quantidadeDeAutorizacoes(msg.sender) >= quantidadeDeAutorizacoesNecessariasParaUmaNovaOuvidoriaPoderSeCadastrar());

        inserirOuvidoriaNoCadastro(msg.sender, nome, tipoEnte, nomeEnte, endpoint);
        ouvidoriaCadastrada(msg.sender, nome, tipoEnte, nomeEnte, endpoint);
    }

    function quantidadeDeAutorizacoes(address contaOuvidoriaCandidata) constant returns (uint) {
        return ouvidoriasCandidatasComAutorizacoes[contaOuvidoriaCandidata].length;
    }

    function quantidadeDeAutorizacoesNecessariasParaUmaNovaOuvidoriaPoderSeCadastrar() constant returns (uint) {
        if (contasOuvidorias.length < NUMERO_DE_AUTORIZACOES_EXIGIDAS_PARA_UMA_NOVA_OUVIDORIA_PODER_CADASTRARSE) {
            return contasOuvidorias.length;
        }
        return NUMERO_DE_AUTORIZACOES_EXIGIDAS_PARA_UMA_NOVA_OUVIDORIA_PODER_CADASTRARSE;
    }

    // converte bytes32 em string
    function toString(bytes32 x) private constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

}
