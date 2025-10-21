import os
import subprocess
from flask import Flask, request, Response, render_template_string, stream_with_context

app = Flask(__name__)

# Constantes com os caminhos dos arquivos e script
INDEXFILE_PATH = "/totvs/http/index.html"
INIFILE_PATH = '/totvs/protheus/bin/appserver/appserver.ini'
CONSOLELOG_PATH = os.environ.get("APPSERVER_CONSOLEFILE", "")
SERVICE_SCRIPT = '/totvs/service.sh'
SERVER_PORT = os.environ.get("APPSERVER_WEB_MANAGER", 8088)

@app.route('/')
def exibir_conteudo_ini():
    """Exibe o conteúdo do arquivo INI em uma página HTML."""
    try:
        with open(INIFILE_PATH, 'r') as f:
            conteudo_arquivo = f.read()
    except FileNotFoundError:
        conteudo_arquivo = ""

    try:
        with open(INDEXFILE_PATH, 'r') as f:
            html_content = f.read()
            html_content = html_content.replace('<!-- O conteúdo do seu arquivo de texto será carregado aqui -->', conteudo_arquivo)
        return render_template_string(html_content, conteudo_arquivo=conteudo_arquivo)
    except FileNotFoundError:
        return 'Arquivo HTML não encontrado', 404

@app.route('/salvar', methods=['POST'])
def salvar_conteudo_ini():
    """Salva o conteúdo enviado no corpo da requisição no arquivo INI."""
    try:
        conteudo_novo = request.get_data().decode('utf-8')
        with open(INIFILE_PATH, 'w') as f:
            f.write(conteudo_novo)
        return 'Arquivo salvo com sucesso!'
    except Exception as e:
        return f'Erro ao salvar o arquivo: {str(e)}', 500

def generate_logs():

    # Executa o subprocesso e obtém a saída em tempo real
    process = subprocess.Popen(['tail', '-n', '200', '-f', CONSOLELOG_PATH], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # Lê a saída do subprocesso linha por linha
    for stdout_line in iter(process.stdout.readline, b""):
        yield f"{stdout_line.decode('utf-8')}"
    
    # Lê a saída de erro, se houver
    for stderr_line in iter(process.stderr.readline, b""):
        yield f"{stderr_line.decode('utf-8')}"

    process.stdout.close()
    process.stderr.close()
    process.wait()

@app.route('/consolelog')
def exibir_console_log():
    return Response(stream_with_context(generate_logs()), mimetype='text/event-stream')

@app.route('/inifile')
def retornar_inifile():
    """Retorna conteudo do arquivo appserver.ini."""
    try:
        with open(INIFILE_PATH, 'r') as f:
            conteudo_arquivo = f.read()
            return conteudo_arquivo
    except FileNotFoundError:
        conteudo_arquivo = ""
        return conteudo_arquivo

@app.route('/status')
def retornar_status_servico():
    """Retorna status do servico."""
    try:
        resultado = subprocess.run(['pgrep', '-f', 'appsrvlinux'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if resultado.returncode == 0:
            return 'Serviço em execução!'
        else:
            mensagem_erro = resultado.stderr.decode("utf-8")
            return f'Erro ao consultar status para o serviço.\n\n{mensagem_erro}', 400
    except Exception:
        return 'Erro ao consultar status para o serviço.', 500

@app.route('/servico/<acao>', methods=['POST'])
def controlar_servico(acao):
    """Controla o serviço externo de acordo com a ação recebida."""

    def service_start():
        return subprocess.run([SERVICE_SCRIPT, 'start'])

    def service_stop():
        return subprocess.run([SERVICE_SCRIPT, 'stop'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def service_restart():
        resultado = service_stop()
        if resultado.returncode == 0:
            resultado = service_start()
        return resultado

    if acao not in ('start', 'stop', 'restart'):
        return 'Ação inválida', 400

    try:
        if acao == "start":
            resultado = service_start()
        elif acao == "stop":
            resultado = service_stop()
        elif acao == 'restart':
            resultado = service_restart()

        if resultado.returncode == 0:
            return f'Serviço {acao} com sucesso!'
        else:
            mensagem_erro = resultado.stderr.decode("utf-8")
            return f'Erro ao realizar {acao} no serviço:\n\n{mensagem_erro}'

    except Exception as e:
        return f'Erro ao {acao} serviço: {str(e)}', 500

if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True, port=SERVER_PORT)
