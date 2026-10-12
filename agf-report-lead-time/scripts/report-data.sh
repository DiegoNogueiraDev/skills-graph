#!/usr/bin/env bash
# Números da rodada para o relatório do Dono, numa chamada só (sem LLM).
# PORQUÊ: montar o status à mão custou tokens e errou (comparar changed_at ISO com
# datetime('now') do sqlite conta o dia inteiro). Aqui o corte usa strftime ISO.
set -u
ROOT="${AGF_GRAPH_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
DB="$ROOT/workflow-graph/graph.db"
[ -f "$DB" ] || { echo "graph.db não encontrado em $ROOT"; exit 1; }
if [ -f "$ROOT/src/cli/index.ts" ]; then AGF=(npx tsx "$ROOT/src/cli/index.ts"); else AGF=(agf); fi
q() { sqlite3 -separator ' | ' "$DB" "$1"; }
since() { echo "strftime('%Y-%m-%dT%H:%M:%S','now','$1')"; }

echo "## carga"; uptime | sed 's/.*load/load/'; echo "núcleos: $(sysctl -n hw.ncpu 2>/dev/null || nproc)"
echo "## main"; git -C "$ROOT" fetch -q origin 2>/dev/null
echo "commits no origin/main desde meia-noite: $(git -C "$ROOT" log origin/main --since=midnight --oneline | wc -l | tr -d ' ')"
git -C "$ROOT" log origin/main --oneline -5 | cut -c1-90
echo "branches remotas fora do main: $(git -C "$ROOT" branch -r --no-merged origin/main 2>/dev/null | wc -l | tr -d ' ')"
echo "## vazão (done)"
for w in "-1 hour" "-3 hours" "-24 hours"; do echo "$w: $(q "select count(*) from node_changelog where field='status' and new_value='done' and changed_at >= $(since "$w")")"; done
echo "por agente, 3 h:"; q "select coalesce(agent_id,'-'), count(*) from node_changelog where field='status' and new_value='done' and changed_at >= $(since '-3 hours') group by 1 order by 2 desc"
echo "## lead e cycle (horas)"
for w in 1 7; do echo "janela ${w}d: $("${AGF[@]}" leadtime --window $w --top 3 2>/dev/null | grep -o '"lead":{[^}]*}\|"cycle":{[^}]*}' | tr '\n' ' ')"; done
echo "## linha de base"
q "select id, substr(description,1,260) from nodes where archived_at is null and type='decision' and tags like '%baseline%' order by created_at desc limit 1"
echo "## em andamento (idade em h)"
q "select coalesce(json_extract(metadata,'\$.claimedBy'),'?'), id, priority, substr(title,1,60), round((julianday('now')-julianday(updated_at))*24,1) from nodes where archived_at is null and status='in_progress' order by 1"
echo "## abertos por frente (p1 | total)"
q "with recursive sub(id,lane) as (select id, replace(substr(tags, instr(tags,'frente-'), instr(substr(tags, instr(tags,'frente-')),'\"')-1),'frente-','') from nodes where archived_at is null and tags like '%frente-%' union select n.id, sub.lane from nodes n join sub on n.parent_id=sub.id where n.archived_at is null) select lane, sum(n.priority=1), count(*) from (select distinct id, lane from sub) s join nodes n using(id) where n.status<>'done' and n.type in ('task','bug') group by lane order by 2 desc"
echo "## abertos por prioridade"; q "select 'p'||priority, count(*) from nodes where archived_at is null and status<>'done' and type in ('task','bug') group by priority"
echo "## bloqueadas: $(q "select count(*) from nodes where archived_at is null and status='blocked'")"
