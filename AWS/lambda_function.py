import json
import os
from datetime import datetime, timezone, timedelta
import boto3

TABELA = os.environ.get("TABELA", "cliques-produtos")
PRODUTOS = {"comoda-madeira", "comoda-azul", "comoda-vintage"}
BRT = timezone(timedelta(hours=-3))

dynamodb = boto3.resource("dynamodb")
tabela = dynamodb.Table(TABELA)


def resposta(status, corpo):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(corpo),
    }


def registrar(produto):
    hora = datetime.now(BRT).strftime("%Y-%m-%dT%H")
    for periodo in ("TOTAL", hora):
        tabela.update_item(
            Key={"produto": produto, "periodo": periodo},
            UpdateExpression="ADD cliques :um",
            ExpressionAttributeValues={":um": 1},
        )
    return resposta(200, {"ok": True, "produto": produto})


def listar():
    itens = tabela.scan()["Items"]
    dados = [
        {
            "produto": i["produto"],
            "periodo": i["periodo"],
            "cliques": int(i["cliques"]),
        }
        for i in itens
    ]
    return resposta(200, dados)


def lambda_handler(event, context):
    rota = event.get("routeKey", "")

    if rota.startswith("POST /clique"):
        produto = (event.get("pathParameters") or {}).get("produto")
        if produto not in PRODUTOS:
            return resposta(400, {"erro": "produto inválido"})
        return registrar(produto)

    if rota.startswith("GET /cliques"):
        return listar()

    return resposta(404, {"erro": "rota não encontrada"})
