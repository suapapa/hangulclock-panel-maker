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
	let panelWidthMM = 165; // mm
	let panelHeightMM = 165; // mm
	let margin = 10;
	let yOffset = 0;
	let dpi = "300"; // 문자열로 선언
	let invertColor = true; // 색상 반전 기본값
	let flipHorizontal = true; // 좌우 반전 기본값
	let paddingWidthMM = 5; // 패딩(가로, mm)
	let paddingHeightMM = 5; // 패딩(세로, mm)

	// mm → px 변환 함수
	function mmToPx(mm, dpi) {
		return Math.round((mm / 25.4) * Number(dpi));
	}

	// 캔버스 참조
	let canvasEl;

	// 캔버스 크기 동기화 및 2D 컨텍스트 준비
	$: canvasWidth = mmToPx(panelWidthMM, dpi);
	$: canvasHeight = mmToPx(panelHeightMM, dpi);
	$: ctx = canvasEl ? canvasEl.getContext('2d') : null;

	// 패널 문자열을 2차원 배열로 변환
	function getPanelGrid() {
		return panelArray.trim().split('\n').map(row => row.split(''));
	}

	// 캔버스에 패널 그리기
	$: if (ctx) {
		ctx.save();
		ctx.clearRect(0, 0, canvasWidth, canvasHeight);

		// 좌우 반전
		if (flipHorizontal) {
			ctx.translate(canvasWidth, 0);
			ctx.scale(-1, 1);
		}

		// 색상 반전
		const bgColor = invertColor ? '#222' : '#f8f8f8';
		const fgColor = invertColor ? '#f8f8f8' : '#222';
		ctx.fillStyle = bgColor;
		ctx.fillRect(0, 0, canvasWidth, canvasHeight);

		const grid = getPanelGrid();
		const rows = grid.length;
		const cols = grid[0].length;

		// 패딩 계산 (mm → px)
		const padW = mmToPx(paddingWidthMM, dpi);
		const padH = mmToPx(paddingHeightMM, dpi);
		const left = padW / 2 + margin;
		const top = padH / 2 + margin + yOffset;
		const drawWidth = canvasWidth - padW - margin * 2;
		const drawHeight = canvasHeight - padH - margin * 2;
		const cellWidth = drawWidth / cols;
		const cellHeight = drawHeight / rows;
		const fontSize = Math.min(cellWidth, cellHeight) * 0.8;

		ctx.textAlign = 'center';
		ctx.textBaseline = 'middle';
		ctx.fillStyle = fgColor;
		ctx.font = `bold ${fontSize}px sans-serif`;

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

	// 캔버스 다운로드 함수
	function downloadCanvas() {
		if (!canvasEl) return;
		const link = document.createElement('a');
		link.href = canvasEl.toDataURL('image/png');
		link.download = `hangulclock_panel_${panelWidthMM}x${panelHeightMM}_${dpi}dpi.png`;
		link.click();
	}

	// 출력 크기 계산
	$: outputWidthMM = Number(panelWidthMM) + Number(paddingWidthMM);
	$: outputHeightMM = Number(panelHeightMM) + Number(paddingHeightMM);
</script>

<main>
	<h1>한글 시계 패널 설정</h1>
	<form autocomplete="off">
		<label>
			패널 가로(mm):
			<input type="number" bind:value={panelWidthMM} min="10" max="500" required />
		</label>
		<label>
			패널 세로(mm):
			<input type="number" bind:value={panelHeightMM} min="10" max="500" required />
		</label>
		<label>
			DPI:
			<select bind:value={dpi} class="dpi-select">
				<option value="150">150</option>
				<option value="200">200</option>
				<option value="300">300</option>
				<option value="600">600</option>
				<option value="1200">1200</option>
			</select>
		</label>
		<label>
			여백(px):
			<input type="number" bind:value={margin} min="0" max="100" required />
		</label>
		<label>
			y-offset(px):
			<input type="number" bind:value={yOffset} min="-100" max="100" required />
		</label>
		<label>
			패널 패딩(가로, mm):
			<input type="number" bind:value={paddingWidthMM} min="0" max="50" required />
		</label>
		<label>
			패널 패딩(세로, mm):
			<input type="number" bind:value={paddingHeightMM} min="0" max="50" required />
		</label>
		<label style="display:flex;align-items:center;gap:0.5em;">
			<input type="checkbox" bind:checked={invertColor} /> 색상 반전 (기본: 반전)
		</label>
		<label style="display:flex;align-items:center;gap:0.5em;">
			<input type="checkbox" bind:checked={flipHorizontal} /> 좌우 반전 (기본: 반전)
		</label>
		<!-- 추가 입력 항목 필요시 여기에 -->
	</form>

	<div style="margin-top:2em;">
		<h2>패널 캔버스 미리보기</h2>
		<canvas
			bind:this={canvasEl}
			width={canvasWidth}
			height={canvasHeight}
			style="border:1px solid #aaa; background:#f8f8f8; max-width:100%; height:auto; display:block; margin:0 auto;"
		></canvas>
	</div>

	<div style="margin-top:2em;">
		<h2>설정값</h2>
		<ul>
			<li>출력 크기: {outputWidthMM}x{outputHeightMM}mm ({canvasWidth}x{canvasHeight}px)</li>
			<li>DPI: {dpi}</li>
			<li>여백: {margin}px</li>
			<li>y-offset: {yOffset}px</li>
		</ul>
	</div>

	<div style="margin-top:2em; text-align:center;">
		<button type="button" on:click={downloadCanvas} style="padding:0.7em 2em; font-size:1.1em; border-radius:4px; border:1px solid #aaa; background:#fff; cursor:pointer;">
			PNG로 다운로드
		</button>
	</div>
</main>

<style>
	main {
		text-align: left;
		padding: 1em;
		max-width: 400px;
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

	input[type="number"], select.dpi-select {
		width: 100%;
		font-family: inherit;
		font-size: inherit;
		padding: 0.4em;
		margin: 0 0 0.5em 0;
		box-sizing: border-box;
		border: 1px solid #ccc;
		border-radius: 2px;
	}
</style>