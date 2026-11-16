set -e
KEY=$(uuidgen)
TITLE="idem-$KEY"

echo "== Запит 1 =="
curl -si -X POST "$BASE_URL/api/notes" -H "Content-Type: application/json" -H "Idempotency-Key: $KEY" -d "{\"title\":\"$TITLE\"}" | tee /tmp/idem1.txt
echo; echo "== Запит 2 (той самий ключ) =="
curl -si -X POST "$BASE_URL/api/notes" -H "Content-Type: application/json" -H "Idempotency-Key: $KEY" -d "{\"title\":\"$TITLE\"}" | tee /tmp/idem2.txt

echo; echo "== Тіла відповідей =="
BODY1=$(tail -n 1 /tmp/idem1.txt)
BODY2=$(tail -n 1 /tmp/idem2.txt)
echo "1: $BODY1"
echo "2: $BODY2"
[ "$BODY1" = "$BODY2" ] && echo "OK: відповіді однакові" || { echo "FAIL: відповіді різні"; exit 1; }

echo; echo "== Кількість записів із цим заголовком у базі =="
if curl -si "$BASE_URL/api/notes" | grep -qi '^x-cache'; then sleep 31; fi
COUNT=$(curl -s "$BASE_URL/api/notes" | grep -o "\"title\":\"$TITLE\"" | wc -l | tr -d ' ')
echo "Записів: $COUNT"
[ "$COUNT" = "1" ] && echo "OK: рівно один запис" || { echo "FAIL: очікувався 1 запис"; exit 1; }
