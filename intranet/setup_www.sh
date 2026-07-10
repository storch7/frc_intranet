#!/bin/bash

echo "Instalando o servidor web Nginx..."
apt update && apt install -y nginx

echo "Criando o diretório da intranet..."
mkdir -p /var/www/intranet

echo "Gerando a página principal (index.html)..."
cat << 'EOF' > /var/www/intranet/index.html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tá pingando — tapingando.com.br</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600;700&family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>

  :root{
    --bg: #0a0f0d;
    --bg-panel: #0e1613;
    --bg-panel-2: #101b17;
    --border: #1d2b26;
    --border-soft: #16211c;
    --text: #e9efe9;
    --text-dim: #82998f;
    --text-dimmer: #4d615a;
    --amber: #ffb000;
    --amber-dim: #7a5600;
    --green: #59e88f;
    --green-dim: #1f4a34;
    --red: #ff5f56;
    --mono: 'IBM Plex Mono', ui-monospace, monospace;
    --sans: 'Inter', -apple-system, sans-serif;
  }

  * { margin:0; padding:0; box-sizing:border-box; }

  html { scroll-behavior:smooth; }

  body{
    background:var(--bg);
    color:var(--text);
    font-family:var(--sans);
    line-height:1.5;
    -webkit-font-smoothing:antialiased;
  }

  body::before{
    content:'';
    position:fixed; inset:0;
    background-image:
      radial-gradient(circle at 15% 8%, rgba(89,232,143,0.06), transparent 40%),
      radial-gradient(circle at 85% 92%, rgba(255,176,0,0.05), transparent 40%);
    pointer-events:none;
    z-index:0;
  }

  a { color:inherit; text-decoration:none; }

  .wrap{
    max-width:1120px;
    margin:0 auto;
    padding:0 32px;
    position:relative;
    z-index:1;
  }

  ::selection{ background:var(--green-dim); color:var(--green); }

  /* ---------- scanline / crt texture on panels ---------- */
  .crt{
    position:relative;
    overflow:hidden;
  }
  .crt::after{
    content:'';
    position:absolute; inset:0;
    background:repeating-linear-gradient(
      to bottom,
      rgba(255,255,255,0.018) 0px,
      rgba(255,255,255,0.018) 1px,
      transparent 1px,
      transparent 3px
    );
    pointer-events:none;
  }

  /* ---------- nav ---------- */
  header{
    position:sticky; top:0; z-index:50;
    background:rgba(10,15,13,0.86);
    backdrop-filter:blur(10px);
    border-bottom:1px solid var(--border-soft);
  }
  .nav{
    display:flex; align-items:center; justify-content:space-between;
    height:64px;
  }
  .brand{
    font-family:var(--mono);
    font-weight:600;
    font-size:15px;
    letter-spacing:-0.02em;
    display:flex; align-items:center; gap:9px;
  }
  .brand .dot{
    width:8px; height:8px; border-radius:50%;
    background:var(--green);
    box-shadow:0 0 8px var(--green);
    animation:blink-dot 1.8s ease-in-out infinite;
  }
  .brand .prompt-glyph{ color:var(--text-dimmer); }
  @keyframes blink-dot{ 0%,100%{opacity:1;} 50%{opacity:0.35;} }

  nav ul{
    display:flex; gap:32px; list-style:none;
    font-family:var(--mono);
    font-size:12.5px;
    color:var(--text-dim);
  }
  nav ul li a{ transition:color .15s; position:relative; }
  nav ul li a:hover{ color:var(--amber); }
  nav ul li a:focus-visible{ outline:1px solid var(--amber); outline-offset:4px; }

  /* ---------- hero ---------- */
  .hero{
    position:relative;
    padding:120px 0 128px;
    overflow:hidden;
    isolation:isolate;
  }
  .hero-content{
    position:relative;
    z-index:2;
    max-width:640px;
  }
  .hero-bg-terminal{
    position:absolute;
    inset:-10% -5% -10% auto;
    right:-4%;
    width:62%;
    z-index:1;
    font-family:var(--mono);
    font-size:13px;
    line-height:2.1;
    color:var(--text-dim);
    -webkit-mask-image:linear-gradient(to bottom, transparent, black 18%, black 78%, transparent),
                        linear-gradient(to left, transparent, black 30%);
    -webkit-mask-composite:source-in;
    mask-image:linear-gradient(to bottom, transparent, black 18%, black 78%, transparent),
               linear-gradient(to left, transparent, black 30%);
    mask-composite:intersect;
    opacity:0.55;
    pointer-events:none;
  }
  .hero-bg-terminal .term-line .ip{ color:var(--text-dim); }
  .hero-bg-terminal .term-line .time{ color:var(--green); opacity:0.8; }
  .hero-bg-terminal .term-line .ttl{ color:var(--text-dimmer); }
  .hero-bg-terminal .term-stats{ color:var(--amber); opacity:0.7; }
  .eyebrow{
    font-family:var(--mono);
    font-size:12px;
    color:var(--green);
    letter-spacing:0.12em;
    text-transform:uppercase;
    display:flex; align-items:center; gap:10px;
    margin-bottom:22px;
  }
  .eyebrow::before{
    content:'';
    width:22px; height:1px;
    background:var(--green);
  }

  h1{
    font-family:var(--sans);
    font-weight:800;
    font-size:52px;
    line-height:1.04;
    letter-spacing:-0.03em;
    margin-bottom:22px;
  }
  h1 .accent{ color:var(--amber); }
  h1 .cursor-blink{
    display:inline-block;
    width:0.5ch;
    background:var(--amber);
    animation:blink-dot 1s steps(1) infinite;
    margin-left:2px;
  }

  .hero p.lede{
    font-size:16.5px;
    color:var(--text-dim);
    max-width:46ch;
    margin-bottom:32px;
  }

  /* ---------- ping ambiente (elemento de assinatura) ---------- */
  .term-line{ color:var(--text-dim); opacity:0; }
  .term-line.show{ animation:line-in .25s ease forwards; }
  @keyframes line-in{ from{opacity:0; transform:translateY(2px);} to{opacity:1; transform:translateY(0);} }
  .term-line .ip{ color:var(--text); }
  .term-line .time{ color:var(--green); }
  .term-line .ttl{ color:var(--text-dimmer); }
  .term-stats{ color:var(--amber); opacity:0; }
  .term-stats.show{ animation:line-in .25s ease forwards; }
  /* ---------- section shells ---------- */
  section{ padding:96px 0; border-top:1px solid var(--border-soft); position:relative; }
  .section-head{ margin-bottom:48px; max-width:640px; }
  .kicker{
    font-family:var(--mono);
    font-size:12px;
    color:var(--text-dimmer);
    text-transform:uppercase;
    letter-spacing:0.1em;
    margin-bottom:12px;
  }
  .kicker::before{ content:'// '; color:var(--green); }
  h2{
    font-size:32px;
    font-weight:800;
    letter-spacing:-0.02em;
    margin-bottom:14px;
  }
  .section-head p{ color:var(--text-dim); font-size:15.5px; max-width:56ch; }

  /* ---------- about / topology ---------- */
  .about-grid{
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:48px;
    align-items:start;
  }
  .about-grid p{ color:var(--text-dim); font-size:15px; margin-bottom:16px; }
  .about-grid strong{ color:var(--text); font-weight:600; }

  .topo{
    background:var(--bg-panel);
    border:1px solid var(--border);
    border-radius:10px;
    font-family:var(--mono);
    font-size:12.5px;
    overflow:hidden;
  }
  .topo-head{
    padding:12px 16px;
    border-bottom:1px solid var(--border-soft);
    color:var(--text-dimmer);
    display:flex; justify-content:space-between;
    background:var(--bg-panel-2);
  }
  .topo-row{
    display:grid;
    grid-template-columns:1.3fr 1fr 1.4fr;
    padding:11px 16px;
    border-bottom:1px solid var(--border-soft);
    gap:8px;
  }
  .topo-row:last-child{ border-bottom:none; }
  .topo-row .dev{ color:var(--text); }
  .topo-row .ip{ color:var(--green); }
  .topo-row .role{ color:var(--text-dim); }

  /* ---------- team ---------- */
  .team-grid{
    display:grid;
    grid-template-columns:repeat(4, 1fr);
    gap:20px;
  }
  .member{
    display:block;
    background:var(--bg-panel);
    border:1px solid var(--border);
    border-radius:10px;
    padding:22px;
    transition:border-color .18s, transform .18s, box-shadow .18s;
  }
  .member:hover{
    border-color:var(--green-dim);
    transform:translateY(-3px);
    box-shadow:0 16px 32px -18px rgba(0,0,0,0.55);
  }
  .member:focus-visible{ outline:1px solid var(--amber); outline-offset:3px; }
  .member:hover .member-meta .visit{ color:var(--amber); }
  .member-top{
    display:flex; align-items:center; gap:12px;
    margin-bottom:16px;
  }
  .member img{
    width:52px; height:52px;
    border-radius:8px;
    border:1px solid var(--border);
    display:block;
  }
  .member-status{
    font-family:var(--mono);
    font-size:10.5px;
    color:var(--green);
    display:flex; align-items:center; gap:5px;
    margin-bottom:2px;
  }
  .member-status .sd{
    width:5px; height:5px; border-radius:50%;
    background:var(--green);
    box-shadow:0 0 5px var(--green);
  }
  .member-name{ font-weight:700; font-size:15px; }
  .member-meta{
    font-family:var(--mono);
    font-size:11.5px;
    color:var(--text-dim);
    border-top:1px solid var(--border-soft);
    padding-top:14px;
  }
  .member-meta div{ display:flex; justify-content:space-between; margin-bottom:6px; }
  .member-meta div:last-child{ margin-bottom:0; }
  .member-meta span:first-child{ color:var(--text-dimmer); }
  .member-meta .visit{ color:var(--text-dim); transition:color .15s; }

  /* ---------- stack ---------- */
  .stack-list{
    display:grid;
    grid-template-columns:repeat(2, 1fr);
    gap:1px;
    background:var(--border-soft);
    border:1px solid var(--border-soft);
    border-radius:10px;
    overflow:hidden;
  }
  .stack-item{
    background:var(--bg-panel);
    padding:20px 22px;
    display:flex;
    align-items:center;
    justify-content:space-between;
    font-family:var(--mono);
    font-size:13px;
  }
  .stack-item .svc{ color:var(--text); font-weight:600; }
  .stack-item .desc{ color:var(--text-dim); font-size:11.5px; display:block; margin-top:4px; font-family:var(--sans); }
  .stack-item .up{
    color:var(--green);
    font-size:11px;
    display:flex; align-items:center; gap:6px;
    white-space:nowrap;
  }
  .stack-item .up .sd{ width:5px; height:5px; border-radius:50%; background:var(--green); box-shadow:0 0 5px var(--green); }

  /* ---------- footer ---------- */
  footer{
    border-top:1px solid var(--border-soft);
    padding:36px 0;
  }
  .foot-row{
    display:flex; justify-content:space-between; align-items:center;
    font-family:var(--mono);
    font-size:12px;
    color:var(--text-dimmer);
  }
  .foot-row a:hover{ color:var(--amber); }

  /* ---------- responsive ---------- */
  @media (max-width: 900px){
    .hero{ padding:64px 0 72px; }
    .hero-bg-terminal{ opacity:0.28; width:100%; right:0; }
    h1{ font-size:38px; }
    .about-grid{ grid-template-columns:1fr; }
    .team-grid{ grid-template-columns:repeat(2, 1fr); }
    .stack-list{ grid-template-columns:1fr; }
    nav ul{ display:none; }
    .topo-row{ grid-template-columns:1fr; gap:2px; }
  }

  @media (prefers-reduced-motion: reduce){
    *{ animation-duration:0.001ms !important; animation-iteration-count:1 !important; }
  }
</style>
</head>
<body>

<header>
  <div class="wrap nav">
    <div class="brand"><span class="dot"></span><span class="prompt-glyph">~$</span> tá_pingando</div>
    <ul>
      <li><a href="#sobre">sobre</a></li>
      <li><a href="#topologia">topologia</a></li>
      <li><a href="#equipe">equipe</a></li>
      <li><a href="#stack">stack</a></li>
    </ul>
  </div>
</header>

<main>

  <!-- HERO -->
  <section class="hero wrap" id="terminal" style="border-top:none; padding-top:88px;">
    <div class="hero-bg-terminal crt" aria-hidden="true">
      <div id="term-lines"></div>
    </div>
    <div class="hero-content">
      <div class="eyebrow">tapingando.com.br · uptime desde a entrega do FRC</div>
      <h1>Sua rede nunca<br>ficou tão <span class="accent">estável</span><span class="cursor-blink">&nbsp;</span></h1>
      <p class="lede">A Tá pingando é a provedora fictícia de infraestrutura de rede criada para a disciplina de Fundamentos de Redes de Computadores (FRC) na UnB — DNS, DHCP, e-mail e web, tudo respondendo no primeiro pacote.</p>
    </div>
  </section>

  <!-- SOBRE -->
  <section id="sobre">
    <div class="wrap">
      <div class="section-head">
        <div class="kicker">sobre o projeto</div>
        <h2>Uma empresa fictícia, uma rede muito real</h2>
        <p>Construída do zero para validar, na prática, tudo que se aprende na teoria de redes.</p>
      </div>

      <div class="about-grid">
        <div>
          <p>A <strong>Tá pingando</strong> nasceu como projeto prático da disciplina de <strong>Fundamentos de Redes de Computadores (FRC)</strong>, na Universidade de Brasília. O objetivo foi projetar e automatizar, via scripts, a intranet completa de uma empresa fictícia: dois roteadores interligados por um link serial ponto a ponto, um servidor central e uma rede de clientes.</p>
          <p>Cada serviço — <strong>DNS, DHCP, e-mail e web</strong> — foi implementado, testado e documentado como se fosse posto em produção, incluindo cenários de falha, como conflitos de DHCP e condições de corrida na negociação PPP.</p>
        </div>
        <div>
          <p>O domínio interno do laboratório é <strong>tapingando.com.br</strong>, resolvido por um BIND9 configurado com zonas direta e reversa. Toda a infraestrutura foi versionada e pode ser recriada com os scripts de automação do repositório.</p>
          <p>O nome do projeto é uma referência direta ao próprio teste de conectividade que valida a rede a cada etapa: se está <strong>pingando</strong>, está no ar.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- TOPOLOGIA -->
  <section id="topologia">
    <div class="wrap">
      <div class="section-head">
        <div class="kicker">mapa de endereçamento</div>
        <h2>Topologia da rede</h2>
        <p>Dois roteadores, um link serial ponto a ponto e duas LANs — a espinha dorsal da intranet.</p>
      </div>

      <div class="topo">
        <div class="topo-head">
          <span>dispositivo / interface</span>
          <span>status: online</span>
        </div>
        <div class="topo-row"><span class="dev">Servidor S</span><span class="ip">172.16.0.2</span><span class="role">DNS · DHCP · E-mail · WWW</span></div>
        <div class="topo-row"><span class="dev">Roteador R1 (LAN)</span><span class="ip">172.16.0.1</span><span class="role">Gateway da LAN #1</span></div>
        <div class="topo-row"><span class="dev">Roteador R1 (PPP)</span><span class="ip">10.0.0.1</span><span class="role">Link ponto a ponto R1 ↔ R2</span></div>
        <div class="topo-row"><span class="dev">Roteador R2 (PPP)</span><span class="ip">10.0.0.2</span><span class="role">Link ponto a ponto R1 ↔ R2</span></div>
        <div class="topo-row"><span class="dev">Roteador R2 (LAN)</span><span class="ip">192.168.0.1</span><span class="role">Gateway da LAN #2</span></div>
        <div class="topo-row"><span class="dev">Cliente X</span><span class="ip">192.168.0.2</span><span class="role">Host da LAN #2 · via DHCP</span></div>
        <div class="topo-row"><span class="dev">Cliente Y</span><span class="ip">192.168.0.3</span><span class="role">Host da LAN #2 · via DHCP</span></div>
      </div>
    </div>
  </section>

  <!-- EQUIPE -->
  <section id="equipe">
    <div class="wrap">
      <div class="section-head">
        <div class="kicker">quem mantém isso no ar</div>
        <h2>Equipe</h2>
        <p>Quatro processos rodando em paralelo para manter a Tá pingando sempre respondendo.</p>
      </div>

      <div class="team-grid">
        <a class="member" href="https://github.com/BrzGab" target="_blank" rel="noopener">
          <div class="member-top">
            <img src="https://github.com/BrzGab.png" alt="Gabriel Lopes" loading="lazy">
            <div>
              <div class="member-status"><span class="sd"></span>online</div>
              <div class="member-name">Gabriel Lopes</div>
            </div>
          </div>
          <div class="member-meta">
            <div><span>matrícula</span><span>231012129</span></div>
            <div><span>github</span><span class="visit">@BrzGab ↗</span></div>
          </div>
        </a>

        <a class="member" href="https://github.com/storch7" target="_blank" rel="noopener">
          <div class="member-top">
            <img src="https://github.com/storch7.png" alt="Guilherme Storch" loading="lazy">
            <div>
              <div class="member-status"><span class="sd"></span>online</div>
              <div class="member-name">Guilherme Storch</div>
            </div>
          </div>
          <div class="member-meta">
            <div><span>matrícula</span><span>211030765</span></div>
            <div><span>github</span><span class="visit">@storch7 ↗</span></div>
          </div>
        </a>

        <a class="member" href="https://github.com/rodrigoFAmaral" target="_blank" rel="noopener">
          <div class="member-top">
            <img src="https://github.com/rodrigoFAmaral.png" alt="Rodrigo Amaral" loading="lazy">
            <div>
              <div class="member-status"><span class="sd"></span>online</div>
              <div class="member-name">Rodrigo Amaral</div>
            </div>
          </div>
          <div class="member-meta">
            <div><span>matrícula</span><span>231011810</span></div>
            <div><span>github</span><span class="visit">@rodrigoFAmaral ↗</span></div>
          </div>
        </a>

        <a class="member" href="https://github.com/FelipeNunesdM" target="_blank" rel="noopener">
          <div class="member-top">
            <img src="https://github.com/FelipeNunesdM.png" alt="Felipe Nunes" loading="lazy">
            <div>
              <div class="member-status"><span class="sd"></span>online</div>
              <div class="member-name">Felipe Nunes</div>
            </div>
          </div>
          <div class="member-meta">
            <div><span>matrícula</span><span>202023627</span></div>
            <div><span>github</span><span class="visit">@FelipeNunesdM ↗</span></div>
          </div>
        </a>
      </div>
    </div>
  </section>

  <!-- STACK -->
  <section id="stack">
    <div class="wrap">
      <div class="section-head">
        <div class="kicker">infraestrutura</div>
        <h2>Stack de serviços</h2>
        <p>Cada serviço, seu papel na intranet e o status de disponibilidade.</p>
      </div>

      <div class="stack-list">
        <div class="stack-item">
          <span class="svc">BIND9<span class="desc">DNS — zona direta e reversa</span></span>
          <span class="up"><span class="sd"></span>up</span>
        </div>
        <div class="stack-item">
          <span class="svc">Kea DHCP<span class="desc">Alocação de IP local e via relay</span></span>
          <span class="up"><span class="sd"></span>up</span>
        </div>
        <div class="stack-item">
          <span class="svc">Postfix<span class="desc">SMTP — envio de e-mail</span></span>
          <span class="up"><span class="sd"></span>up</span>
        </div>
        <div class="stack-item">
          <span class="svc">Dovecot<span class="desc">POP3 / IMAP — recebimento de e-mail</span></span>
          <span class="up"><span class="sd"></span>up</span>
        </div>
        <div class="stack-item">
          <span class="svc">Nginx<span class="desc">Servidor web da intranet</span></span>
          <span class="up"><span class="sd"></span>up</span>
        </div>
        <div class="stack-item">
          <span class="svc">PPP · 115200 bps<span class="desc">Link serial R1 ↔ R2</span></span>
          <span class="up"><span class="sd"></span>up</span>
        </div>
      </div>
    </div>
  </section>

</main>

<footer>
  <div class="wrap foot-row">
    <span>tapingando.com.br · projeto acadêmico, FRC — UnB</span>
    <span><a href="#sobre">voltar ao topo ↑</a></span>
  </div>
</footer>

<script>
  // Ping contínuo rolando ao fundo do hero (elemento decorativo, ambiente)
  (function(){
    const linesEl = document.getElementById('term-lines');
    const host = 'tapingando.com.br';
    const ip = '172.16.0.2';
    const MAX_LINES = 16;
    let seq = 0;
    let running = false;
    let timer = null;

    function makeLine(html, extraClass){
      const div = document.createElement('div');
      div.className = 'term-line' + (extraClass ? ' ' + extraClass : '');
      div.innerHTML = html;
      return div;
    }

    function randomLatency(){
      return (0.4 + Math.random() * 1.8).toFixed(2);
    }

    function pushLine(el){
      linesEl.appendChild(el);
      requestAnimationFrame(() => el.classList.add('show'));
      while (linesEl.children.length > MAX_LINES){
        linesEl.removeChild(linesEl.firstElementChild);
      }
    }

    function pingCycle(){
      seq++;

      if (seq % 6 === 0){
        pushLine(makeLine(
          `— ${host} ping statistics — 0% packet loss`,
          'term-stats'
        ));
        timer = setTimeout(pingCycle, 2200);
        return;
      }

      if (seq % 6 === 1){
        pushLine(makeLine(
          `PING <span class="ip">${host} (${ip})</span> 56(84) bytes of data.`
        ));
        timer = setTimeout(pingCycle, 420);
        return;
      }

      pushLine(makeLine(
        `64 bytes from <span class="ip">${ip}</span>: icmp_seq=${seq} ttl=<span class="ttl">64</span> time=<span class="time">${randomLatency()} ms</span>`
      ));
      timer = setTimeout(pingCycle, 620);
    }

    // roda enquanto o hero estiver visível; pausa fora da viewport
    const heroSection = document.getElementById('terminal');
    const io = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !running){
          running = true;
          pingCycle();
        } else if (!entry.isIntersecting && running){
          running = false;
          clearTimeout(timer);
        }
      });
    }, { threshold: 0.05 });
    io.observe(heroSection);
  })();
</script>

</body>
</html>

EOF

echo "Criando o arquivo de configuração do site no Nginx..."
cat << 'EOF' > /etc/nginx/sites-available/intranet
server {
    listen 80;
    server_name www.tapingando.com.br intranet.tapingando.com.br tapingando.com.br;

    root /var/www/intranet;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

echo "Ativando o site da intranet e removendo a configuração padrão..."
# Cria o link simbólico para ativar o site
ln -sf /etc/nginx/sites-available/intranet /etc/nginx/sites-enabled/intranet
# Remove o site padrão para evitar conflitos na porta 80
rm -f /etc/nginx/sites-enabled/default

echo "Testando a sintaxe da configuração do Nginx..."
nginx -t

echo "Reiniciando e habilitando o serviço Nginx..."
systemctl restart nginx
systemctl start nginx

echo "========================================="
echo "Configuração do WWW concluída com sucesso!"
echo "Status do Nginx:"
systemctl status nginx --no-pager | head -n 5
echo "========================================="