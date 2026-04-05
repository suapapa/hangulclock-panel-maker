<script>
	let { name = 'world' } = $props();

	// 패널 배열 문자열
	const panelArray = `
열한다세네
두여섯일곱
여덟아홉시
자정이삼십
사오십오분
	`;

	// 상태 변수 선언 (Runes 적용)
	let panelSizeMM = $state(165); // 정사각형 패널 한 변(mm)
	let paddingMM = $state(5); // 정사각형 패딩 한 변(mm)
	let margin = $state(10);
	let yOffset = $state(0);
	let dpi = $state("300"); // 문자열로 선언
	let invertColor = $state(true); // 색상 반전 기본값
	let flipHorizontal = $state(false); // 좌우 반전 기본값
	let fontType = $state("web"); // 'web' 또는 'ttf'
	let webFontUrl = $state("");
	let ttfFile = $state(null);
	let fontFamily = $state("sans-serif");
	let ttfFontDataUrl = $state("");
	let ttfFontLoaded = $state(false);
	let showSidebar = $state(true);
	let fontReadyVersion = $state(0); // 웹폰트 로드 invalidate용 더미 상태 변수

	// mm → px 변환 함수
	function mmToPx(mm, dpi) {
		return Math.round((mm / 25.4) * Number(dpi));
	}

	// 캔버스 참조
	let canvasEl = $state();

	// 캔버스 크기 계산 (Derived 적용)
	let canvasWidth = $derived(mmToPx(panelSizeMM, dpi));
	let canvasHeight = $derived(mmToPx(panelSizeMM, dpi));
	let outputSizeMM = $derived(Number(panelSizeMM) + Number(paddingMM));

	// 캔버스 컨텍스트
	let ctx = $state(null);

	// 패널 문자열을 2차원 배열로 변환
	function getPanelGrid() {
		return panelArray
			.trim()
			.split("\n")
			.map((row) => row.split(""));
	}

	// 웹폰트 적용 로직 (Effect 적용)
	$effect(() => {
		if (fontType === "web" && webFontUrl) {
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
				const extractedFontFamily = decodeURIComponent(match[1]).replace(/\+/g, " ");
				fontFamily = extractedFontFamily;
				// 폰트 로드 대기 후 invalidate
				document.fonts.load(`bold 32px '${extractedFontFamily}'`).then(() => {
					fontReadyVersion += 1;
				});
			}
		}
	});

	// TTF 업로드 처리
	async function handleTtfUpload(event) {
		const file = event.target.files[0];
		if (!file) return;
		const reader = new FileReader();
		reader.onload = async (e) => {
			ttfFontDataUrl = e.target.result;
			const uploadedFontFamily = file.name.replace(/\.[^.]+$/, "");
			fontFamily = uploadedFontFamily;
			// FontFace API로 동적 폰트 등록 및 로드
			const fontFace = new FontFace(uploadedFontFamily, `url(${ttfFontDataUrl})`);
			await fontFace.load();
			ttfFontLoaded = false;
			document.fonts.add(fontFace);
			ttfFontLoaded = true;
		};
		reader.readAsDataURL(file);
	}

	// 캔버스 그리기 로직 (Effect 적용)
	$effect(() => {
		// 종속성 선언: 폰트 로드 상태나 옵션 변경 시 재호출
		fontReadyVersion; 
		const currentFontLoaded = ttfFontLoaded;
		const currentFontFamily = fontFamily;
		const currentFontType = fontType;
		const currentPanelSize = panelSizeMM;
		const currentPadding = paddingMM;
		const currentMargin = margin;
		const currentYOffset = yOffset;
		const currentDpi = dpi;
		const currentInvertColor = invertColor;
		const currentFlipHorizontal = flipHorizontal;

		if (canvasEl) {
			ctx = canvasEl.getContext("2d");
			if (ctx) {
				if (currentFontType === "ttf" && !currentFontLoaded) {
					// TTF 폰트가 로드될 때까지 렌더링 건너뜀
				} else {
					ctx.save();
					ctx.clearRect(0, 0, canvasWidth, canvasHeight);
					if (currentFlipHorizontal) {
						ctx.translate(canvasWidth, 0);
						ctx.scale(-1, 1);
					}
					const bgColor = currentInvertColor ? "#000000" : "#ffffff";
					const fgColor = currentInvertColor ? "#ffffff" : "#000000";
					ctx.fillStyle = bgColor;
					ctx.fillRect(0, 0, canvasWidth, canvasHeight);
					
					const grid = getPanelGrid();
					const rows = grid.length;
					const cols = grid[0].length;
					
					const padW = mmToPx(currentPadding, currentDpi);
					const padH = mmToPx(currentPadding, currentDpi);
					const left = padW / 2 + currentMargin;
					const top = padH / 2 + currentMargin + currentYOffset;
					
					const drawWidth = canvasWidth - padW - currentMargin * 2;
					const drawHeight = canvasHeight - padH - currentMargin * 2;
					
					const cellWidth = drawWidth / cols;
					const cellHeight = drawHeight / rows;
					const fontSize = Math.min(cellWidth, cellHeight) * 0.8;
					
					ctx.textAlign = "center";
					ctx.textBaseline = "middle";
					ctx.fillStyle = fgColor;
					ctx.font = `bold ${fontSize}px '${currentFontFamily}', sans-serif`;
					
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
	});

	// 캔버스 다운로드 함수
	function downloadCanvas() {
		if (!canvasEl) return;
		const link = document.createElement("a");
		link.href = canvasEl.toDataURL("image/png");
		link.download = `hangulclock_panel_${outputSizeMM}x${outputSizeMM}_${dpi}dpi.png`;
		link.click();
	}
</script>

<main>
	<!-- Floating Action Buttons for mobile or quick access -->
	<div class="floating-actions">
		<button
			class="action-btn toggle-btn"
			onclick={() => (showSidebar = !showSidebar)}
			aria-label="사이드바 토글"
			title="사이드바 토글"
		>
			{#if showSidebar}
				<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
			{:else}
				<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
			{/if}
		</button>
		
		{#if !showSidebar}
		<button
			class="action-btn dl-btn"
			onclick={downloadCanvas}
			aria-label="PNG로 다운로드"
			title="다운로드"
		>
			<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
		</button>
		{/if}
	</div>

	<div class="app-layout {showSidebar ? 'sidebar-open' : 'sidebar-closed'}">
		{#if showSidebar}
			<aside class="sidebar glass-panel">
				<div class="sidebar-header">
					<h1>한글 시계 패널</h1>
					<p class="subtitle">고해상도 도면 생성기</p>
				</div>
				<form autocomplete="off" class="config-form">
					<fieldset>
						<legend>글꼴 설정</legend>
						
						<label class="select-label">
							<span>방식</span>
							<select bind:value={fontType}>
								<option value="web">웹폰트 링크</option>
								<option value="ttf">TTF 파일 업로드</option>
							</select>
						</label>

						<div class="font-input-container">
							{#if fontType === "web"}
								<input
									type="text"
									placeholder="Google Fonts URL (예: family=Noto+Sans+KR)"
									bind:value={webFontUrl}
								/>
							{:else}
								<div class="file-upload-wrapper">
									<input
										type="file"
										id="ttf-upload"
										accept=".ttf,.otf"
										onchange={handleTtfUpload}
									/>
									<label for="ttf-upload" class="file-upload-btn">
										폰트 파일 선택...
									</label>
								</div>
							{/if}
						</div>

						<div class="selected-font-info">
							입력 글꼴: <strong>{fontFamily}</strong>
						</div>
					</fieldset>

					<fieldset>
						<legend>크기 및 여백</legend>
						<div class="input-grid">
							<label>
								<span>패널 크기 (mm)</span>
								<input type="number" bind:value={panelSizeMM} min="10" max="500" required />
							</label>
							<label>
								<span>패딩 (mm)</span>
								<input type="number" bind:value={paddingMM} min="0" max="50" required />
							</label>
							<label>
								<span>여백 (px)</span>
								<input type="number" bind:value={margin} min="0" max="100" required />
							</label>
							<label>
								<span>y-오프셋 (px)</span>
								<input type="number" bind:value={yOffset} min="-100" max="100" required />
							</label>
						</div>
					</fieldset>

					<fieldset class="options-fieldset">
						<legend>효과 옵션</legend>
						<div class="checkbox-group">
							<label class="checkbox-label">
								<input type="checkbox" bind:checked={invertColor} />
								<span class="custom-checkbox"></span>
								색상 반전
							</label>
							<label class="checkbox-label">
								<input type="checkbox" bind:checked={flipHorizontal} />
								<span class="custom-checkbox"></span>
								좌우 반전 (후면 출력용)
							</label>
						</div>
					</fieldset>

					<button type="button" class="primary-dl-btn" onclick={downloadCanvas}>
						<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
						고해상도 이미지 다운로드
					</button>
				</form>
			</aside>
		{/if}

		<div class="main-content">
			<div class="canvas-presentation">
				<div class="presentation-header">
					<div class="dimensions">
						출력 기준치: <span>{outputSizeMM}</span> mm × <span>{outputSizeMM}</span> mm @ {dpi} DPI
					</div>
				</div>
				<div class="canvas-wrapper {invertColor ? 'dark-mode' : 'light-mode'}">
					<canvas
						bind:this={canvasEl}
						width={canvasWidth}
						height={canvasHeight}
						class="preview-canvas"
					></canvas>
				</div>
				<footer class="app-footer">
					© Homin Lee &lt;homin.crc@gmail.com&gt; All rights reserved.
				</footer>
			</div>
		</div>
	</div>
</main>

<style>
	main {
		width: 100vw;
		height: 100vh;
		overflow: hidden;
		background: transparent;
	}

	.app-layout {
		display: flex;
		flex-direction: row;
		width: 100%;
		height: 100%;
		transition: all var(--transition);
	}

	/* Floating Actions */
	.floating-actions {
		position: absolute;
		top: 1.5rem;
		left: 1.5rem;
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
		z-index: 50;
	}

	.action-btn {
		width: 44px;
		height: 44px;
		border-radius: 50%;
		background: var(--surface-bg);
		border: 1px solid var(--surface-border);
		backdrop-filter: blur(8px);
		-webkit-backdrop-filter: blur(8px);
		padding: 0;
		color: var(--text-main);
		box-shadow: var(--shadow-md);
		display: flex;
		align-items: center;
		justify-content: center;
		transition: transform var(--transition), box-shadow var(--transition);
	}

	.action-btn:hover {
		transform: translateY(-2px);
		box-shadow: var(--shadow-lg);
		background: white;
		color: var(--primary-color);
	}

	.action-btn svg {
		width: 20px;
		height: 20px;
	}

	/* Sidebar Styling */
	.sidebar {
		width: 420px;
		min-width: 320px;
		height: 100%;
		overflow-y: auto;
		background: var(--surface-bg);
		backdrop-filter: blur(12px);
		-webkit-backdrop-filter: blur(12px);
		border-right: 1px solid var(--surface-border);
		box-shadow: 1px 0 24px rgba(0, 0, 0, 0.04);
		padding: 2.5rem 2rem;
		box-sizing: border-box;
		display: flex;
		flex-direction: column;
		z-index: 10;
		scrollbar-width: none;
	}
	.sidebar::-webkit-scrollbar { display: none; }

	.sidebar-header {
		margin-bottom: 2rem;
		margin-top: 3rem;
	}

	.sidebar-header h1 {
		font-size: 1.75rem;
		font-weight: 800;
		color: var(--primary-color);
		margin: 0;
		letter-spacing: -0.02em;
	}

	.sidebar-header .subtitle {
		font-size: 0.95rem;
		font-weight: 500;
		color: var(--text-muted);
		margin: 0.25rem 0 0 0;
	}

	.config-form {
		display: flex;
		flex-direction: column;
		gap: 1.25rem;
	}

	.select-label {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		margin-bottom: 0.5rem;
	}
	
	.select-label span {
		flex-shrink: 0;
		font-weight: 600;
		font-size: 0.9rem;
	}

	.select-label select {
		margin: 0;
		flex-grow: 1;
		cursor: pointer;
	}

	.font-input-container {
		margin-top: 0.75rem;
	}

	.font-input-container input[type="text"] {
		width: 100%;
		margin: 0;
	}

	/* Custom File Upload */
	.file-upload-wrapper {
		position: relative;
		overflow: hidden;
		display: inline-block;
		width: 100%;
	}
	
	.file-upload-wrapper input[type="file"] {
		font-size: 100px;
		position: absolute;
		left: 0;
		top: 0;
		opacity: 0;
		cursor: pointer;
		height: 100%;
	}
	
	.file-upload-btn {
		display: block;
		text-align: center;
		background: #fff;
		border: 1px dashed var(--primary-color);
		color: var(--primary-color);
		padding: 0.8rem;
		border-radius: var(--radius-md);
		font-weight: 500;
		cursor: pointer;
		transition: all var(--transition);
	}

	.file-upload-wrapper:hover .file-upload-btn {
		background: var(--primary-color);
		color: white;
	}

	.selected-font-info {
		margin-top: 0.75rem;
		font-size: 0.85rem;
		color: var(--text-muted);
		background: rgba(0, 0, 0, 0.03);
		padding: 0.5rem 0.75rem;
		border-radius: var(--radius-sm);
	}

	.selected-font-info strong {
		color: var(--text-main);
	}

	.input-grid {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 0.75rem 1rem;
	}

	.input-grid label {
		margin: 0;
	}
	
	.input-grid span {
		display: block;
		font-size: 0.85rem;
		margin-bottom: 0.4rem;
		color: var(--text-muted);
	}

	.input-grid input {
		width: 100%;
		margin: 0;
	}

	/* Custom Checkboxes */
	.checkbox-group {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.checkbox-label {
		display: flex;
		align-items: center;
		cursor: pointer;
		margin: 0;
		font-weight: 500;
		font-size: 0.95rem;
		user-select: none;
	}

	.checkbox-label input[type="checkbox"] {
		position: absolute;
		opacity: 0;
		cursor: pointer;
		height: 0;
		width: 0;
	}

	.custom-checkbox {
		height: 20px;
		width: 20px;
		background-color: var(--surface-bg);
		border: 2px solid var(--border-color);
		border-radius: 4px;
		margin-right: 10px;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: all 0.2s ease;
	}

	.checkbox-label:hover input ~ .custom-checkbox {
		border-color: var(--primary-hover);
	}

	.checkbox-label input:checked ~ .custom-checkbox {
		background-color: var(--primary-color);
		border-color: var(--primary-color);
	}

	.custom-checkbox:after {
		content: "";
		display: none;
		width: 5px;
		height: 10px;
		border: solid white;
		border-width: 0 2px 2px 0;
		transform: rotate(45deg);
		margin-top: -2px;
	}

	.checkbox-label input:checked ~ .custom-checkbox:after {
		display: block;
	}

	.primary-dl-btn {
		margin-top: 1rem;
		width: 100%;
		padding: 1rem;
		font-size: 1rem;
		border-radius: var(--radius-lg);
		background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-active) 100%);
		box-shadow: 0 4px 15px rgba(37, 99, 235, 0.3);
		color: white;
	}

	.primary-dl-btn:hover {
		box-shadow: 0 6px 20px rgba(37, 99, 235, 0.4);
		transform: translateY(-2px);
	}
	
	.primary-dl-btn svg {
		margin-right: 0.5rem;
	}

	/* Main Canvas Area */
	.main-content {
		flex: 1;
		display: flex;
		flex-direction: column;
		padding: 2rem;
		height: 100%;
		box-sizing: border-box;
		overflow: hidden;
	}

	.canvas-presentation {
		display: flex;
		flex-direction: column;
		width: 100%;
		height: 100%;
		max-width: 1200px;
		margin: 0 auto;
	}

	.presentation-header {
		display: flex;
		justify-content: flex-end;
		margin-bottom: 1rem;
	}

	.dimensions {
		background: var(--surface-bg);
		padding: 0.5rem 1rem;
		border-radius: 20px;
		font-size: 0.85rem;
		font-weight: 600;
		color: var(--text-muted);
		box-shadow: var(--shadow-sm);
		backdrop-filter: blur(4px);
		border: 1px solid var(--surface-border);
	}

	.dimensions span {
		color: var(--primary-color);
	}

	.canvas-wrapper {
		flex: 1;
		display: flex;
		align-items: center;
		justify-content: center;
		border-radius: var(--radius-lg);
		box-shadow: inset 0 2px 10px rgba(0, 0, 0, 0.02);
		padding: 2rem;
		overflow: auto;
		border: 1px solid var(--surface-border);
		transition: background var(--transition);
	}

	.canvas-wrapper.light-mode {
		background: rgba(0, 0, 0, 0.03);
	}

	.canvas-wrapper.dark-mode {
		background: rgba(255, 255, 255, 0.7);
	}

	.preview-canvas {
		background: #ffffff;
		display: block;
		box-shadow: var(--shadow-lg);
		max-width: 100%;
		max-height: 100%;
		object-fit: contain;
		transition: transform var(--transition);
		border-radius: 4px;
	}

	.preview-canvas:hover {
		transform: scale(1.01);
	}

	.app-footer {
		text-align: center;
		padding-top: 1.5rem;
		font-size: 0.85rem;
		color: var(--text-muted);
		opacity: 0.8;
	}

	/* Responsive */
	@media (max-width: 900px) {
		.app-layout {
			flex-direction: column;
		}
		
		.sidebar {
			width: 100%;
			max-width: 100%;
			height: auto;
			max-height: 55vh;
			border-right: none;
			border-bottom: 1px solid var(--border-color);
			padding: 4.5rem 1.5rem 2rem 1.5rem;
			box-shadow: 0 4px 12px rgba(0,0,0,0.05);
		}

		.main-content {
			height: 45vh;
			padding: 1rem;
		}

		.floating-actions {
			top: 1rem;
			left: 1rem;
			flex-direction: row;
		}
	}
</style>
