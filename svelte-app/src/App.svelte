<script>
	export let name;

	// 패널 배열 문자열
	const panelArray = `
열한다세네
두여섯일곱
여덟아홉시
자정이삼십
사오십오분
	`;

	// 상태 변수 선언
	let panelSizeMM = 165; // 정사각형 패널 한 변(mm)
	let paddingMM = 5; // 정사각형 패딩 한 변(mm)
	let margin = 10;
	let yOffset = 0;
	let dpi = "300"; // 문자열로 선언
	let invertColor = true; // 색상 반전 기본값
	let flipHorizontal = true; // 좌우 반전 기본값
	let fontType = "web"; // 'web' 또는 'ttf'
	let webFontUrl = "";
	let ttfFile = null;
	let fontFamily = "sans-serif";
	let ttfFontDataUrl = "";
	let ttfFontLoaded = false;
	let showSidebar = true;

	// mm → px 변환 함수
	function mmToPx(mm, dpi) {
		return Math.round((mm / 25.4) * Number(dpi));
	}

	// 캔버스 참조
	let canvasEl;

	// 캔버스 크기 동기화 및 2D 컨텍스트 준비
	$: canvasWidth = mmToPx(panelSizeMM, dpi);
	$: canvasHeight = mmToPx(panelSizeMM, dpi);
	$: ctx = canvasEl ? canvasEl.getContext("2d") : null;

	// 패널 문자열을 2차원 배열로 변환
	function getPanelGrid() {
		return panelArray
			.trim()
			.split("\n")
			.map((row) => row.split(""));
	}

	// 웹폰트 적용 함수
	$: if (fontType === "web" && webFontUrl) {
		const id = "dynamic-webfont";
		let link = document.getElementById(id);
		if (!link) {
			link = document.createElement("link");
			link.rel = "stylesheet";
			link.id = id;
			document.head.appendChild(link);
		}
		link.href = webFontUrl;
		// 폰트 패밀리 추출 (예: url에 family=Nanum+Gothic)
		const match = webFontUrl.match(/family=([^&:]+)/);
		if (match) {
			fontFamily = decodeURIComponent(match[1]).replace(/\+/g, " ");
		}
	}

	// TTF 업로드 처리
	async function handleTtfUpload(event) {
		const file = event.target.files[0];
		if (!file) return;
		const reader = new FileReader();
		reader.onload = async (e) => {
			ttfFontDataUrl = e.target.result;
			fontFamily = file.name.replace(/\.[^.]+$/, "");
			// FontFace API로 동적 폰트 등록 및 로드
			const fontFace = new FontFace(fontFamily, `url(${ttfFontDataUrl})`);
			await fontFace.load();
			ttfFontLoaded = false;
			document.fonts.add(fontFace);
			ttfFontLoaded = true;
		};
		reader.readAsDataURL(file);
	}

	// 캔버스에 패널 그리기 (폰트 적용)
	$: {
		if (ctx) {
			if (fontType === "ttf" && !ttfFontLoaded) {
				// TTF 폰트가 로드될 때까지 렌더링 건너뜀
			} else {
				ctx.save();
				ctx.clearRect(0, 0, canvasWidth, canvasHeight);
				if (flipHorizontal) {
					ctx.translate(canvasWidth, 0);
					ctx.scale(-1, 1);
				}
				const bgColor = invertColor ? "#222" : "#f8f8f8";
				const fgColor = invertColor ? "#f8f8f8" : "#222";
				ctx.fillStyle = bgColor;
				ctx.fillRect(0, 0, canvasWidth, canvasHeight);
				const grid = getPanelGrid();
				const rows = grid.length;
				const cols = grid[0].length;
				const padW = mmToPx(paddingMM, dpi);
				const padH = mmToPx(paddingMM, dpi);
				const left = padW / 2 + margin;
				const top = padH / 2 + margin + yOffset;
				const drawWidth = canvasWidth - padW - margin * 2;
				const drawHeight = canvasHeight - padH - margin * 2;
				const cellWidth = drawWidth / cols;
				const cellHeight = drawHeight / rows;
				const fontSize = Math.min(cellWidth, cellHeight) * 0.8;
				ctx.textAlign = "center";
				ctx.textBaseline = "middle";
				ctx.fillStyle = fgColor;
				ctx.font = `bold ${fontSize}px '${fontFamily}', sans-serif`;
				for (let y = 0; y < rows; y++) {
					for (let x = 0; x < cols; x++) {
						const char = grid[y][x];
						const cx = left + cellWidth * x + cellWidth / 2;
						const cy = top + cellHeight * y + cellHeight / 2;
						ctx.fillText(char, cx, cy);
					}
				}
				ctx.restore();
			}
		}
	}

	// 캔버스 다운로드 함수
	function downloadCanvas() {
		if (!canvasEl) return;
		const link = document.createElement("a");
		link.href = canvasEl.toDataURL("image/png");
		link.download = `hangulclock_panel_${panelSizeMM}x${panelSizeMM}_${dpi}dpi.png`;
		link.click();
	}

	// 출력 크기 계산
	$: outputSizeMM = Number(panelSizeMM) + Number(paddingMM);
</script>

<main>
	<button
		class="sidebar-toggle-btn button"
		on:click={() => (showSidebar = !showSidebar)}
	>
		{showSidebar ? "◀" : "▶"}
	</button>
	<div class="app-layout">
		{#if showSidebar}
			<div class="sidebar">
				<h1 style="margin-top:0;">한글 시계 패널 생성기</h1>
				<!-- <h2 style="margin-bottom:0.5em;">패널 설정</h2> -->
				<form autocomplete="off">
					<fieldset
						style="margin:1em 0; padding:1em; border:1px solid #ccc;"
					>
						<legend>글꼴 선택</legend>
						<label style="margin-right:1em;"
							><input
								type="radio"
								bind:group={fontType}
								value="web"
							/> 웹폰트</label
						>
						<label
							><input
								type="radio"
								bind:group={fontType}
								value="ttf"
							/> TTF 업로드</label
						>
						{#if fontType === "web"}
							<input
								type="text"
								placeholder="웹폰트 링크 (Google Fonts 등)"
								bind:value={webFontUrl}
								style="width:80%;margin-top:0.5em;"
								class="webfont-input"
							/>
						{/if}
						{#if fontType === "ttf"}
							<input
								type="file"
								accept=".ttf,.otf"
								on:change={handleTtfUpload}
								style="margin-top:0.5em;"
								class="ttf-input"
							/>
						{/if}
						<div
							style="margin-top:0.5em; font-size:0.95em; color:#666;"
						>
							현재 적용 폰트: <b>{fontFamily}</b>
						</div>
					</fieldset>
					<label
						>패널 크기(mm):
						<input
							type="number"
							bind:value={panelSizeMM}
							min="10"
							max="500"
							required
						/>
					</label>
					<label
						>패널 패딩(mm):
						<input
							type="number"
							bind:value={paddingMM}
							min="0"
							max="50"
							required
						/>
					</label>
					<label
						>DPI:
						<select bind:value={dpi} class="dpi-select">
							<option value="150">150</option>
							<option value="200">200</option>
							<option value="300">300</option>
							<option value="600">600</option>
							<option value="1200">1200</option>
						</select>
					</label>
					<label
						>여백(px):
						<input
							type="number"
							bind:value={margin}
							min="0"
							max="100"
							required
						/>
					</label>
					<label
						>y-offset(px):
						<input
							type="number"
							bind:value={yOffset}
							min="-100"
							max="100"
							required
						/>
					</label>
					<label style="display:flex;align-items:center;gap:0.5em;"
						><input type="checkbox" bind:checked={invertColor} /> 색상
						반전</label
					>
					<label style="display:flex;align-items:center;gap:0.5em;"
						><input type="checkbox" bind:checked={flipHorizontal} />
						좌우 반전</label
					>
				</form>
				<div style="margin-top:2em; text-align:center;">
					<button
						type="button"
						on:click={downloadCanvas}
						class="button"
					>
						PNG로 다운로드
					</button>
				</div>
			</div>
		{/if}
		<div class="main-content">
			<div style="margin-top:2em;">
				<canvas
					bind:this={canvasEl}
					width={canvasWidth}
					height={canvasHeight}
					style="background:#f8f8f8; max-width:100%; height:auto; display:block; margin:0 auto;"
				></canvas>
			</div>
		</div>
	</div>
</main>

<style>
	main {
		text-align: left;
		padding: 1em;
		max-width: 80%;
		margin: 0 auto;
	}

	h1 {
		color: #ff3e00;
		font-size: 2em;
		font-weight: 700;
		margin-bottom: 1em;
	}

	form label {
		display: block;
		margin-bottom: 1em;
	}

	input[type="number"],
	select.dpi-select,
	input[type="file"],
	input[type="text"] {
		width: 100%;
		font-family: inherit;
		font-size: inherit;
		padding: 0.4em;
		margin: 0 0 0.5em 0;
		box-sizing: border-box;
		border: 1px solid #ccc;
		border-radius: 2px;
	}

	.button {
		padding: 0.7em 2em;
		font-size: 1.1em;
		border-radius: 4px;
		border: 1px solid #aaa;
		background: #fff;
		cursor: pointer;
		transition: background 0.2s;
	}
	.button:hover {
		background: #f0f0f0;
	}

	.app-layout {
		display: flex;
		flex-direction: row;
		align-items: flex-start;
		width: 100vw;
		max-width: 100vw;
		box-sizing: border-box;
		margin: 0;
		padding: 0;
	}
	.sidebar {
		width: 320px;
		min-width: 220px;
		max-width: 400px;
		/* background: #f4f4f4; */
		padding-right: 1em;
		border-right: 1px solid #ddd;
		box-sizing: border-box;
		position: static;
		top: 0;
		z-index: 10;
		color: #222;
	}
	.sidebar-toggle-btn {
		position: fixed;
		top: 1em;
		left: 1em;
		background: #fff;
		border: 1px solid #aaa;
		border-radius: 0 4px 4px 0;
		padding: 0.5em 0.8em;
		cursor: pointer;
		box-shadow: 1px 1px 4px #0001;
		z-index: 100;
	}
	.main-content {
		flex: 1;
		padding: 1.5em 1em 1em 1em;
		min-width: 0;
		box-sizing: border-box;
		width: 100%;
		max-width: 100vw;
		overflow-x: auto;
		max-height: 100vh;
	}
	@media (max-width: 900px) {
		.app-layout {
			flex-direction: column;
		}
		.sidebar {
			width: 100vw;
			max-width: 100vw;
			min-width: 0;
			border-right: none;
			border-bottom: 1px solid #ddd;
			position: static;
			height: 100vh;
			min-height: 100vh;
		}
		.main-content {
			padding: 1em 0.5em;
		}
	}
	@media (max-width: 600px) {
		h1 {
			font-size: 1.3em;
		}
		.button {
			font-size: 1em;
			padding: 0.5em 1em;
		}
	}
	canvas {
		background: #f8f8f8;
		display: block;
		margin: 0 auto;
		max-width: 100%;
		max-height: 80vh;
		object-fit: contain;
		height: auto;
	}
</style>
