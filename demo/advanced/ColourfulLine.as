package advanced 
{
	import cn.flashhawk.spp.particles.*;
	import cn.flashhawk.spp.physics.forces.BrownForce;

	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;

	/**
	 * @author flashhawk
	 */
	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]

	public class ColourfulLine extends Sprite 
	{
		public var particleSystem : ParticlesSystem;
		public var lineCanvas : Sprite;
		private var blurBmd : CanvasBitmapData;
		private var blurBmp : Bitmap;

		private var matrix : Matrix = new Matrix();

		private var r : Number = 255; 
		private var g : Number = 127; 
		private var b : Number = 0; 

		private var ri : Number = 0.02;
		private var gi : Number = 0.015; 
		private var bi : Number = 0.025; 
		private var logo:Logo;

		public function ColourfulLine()
		{
			particleSystem = new ParticlesSystem();
			
			matrix.scale(0.1, 0.1);
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e : Event) : void
		{
			lineCanvas = new Sprite();
			lineCanvas.graphics.lineStyle(1, 0xffffff);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, createFlow);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, initBitmapCanvas);
			initBitmapCanvas();
			particleSystem.startRendering();
			//addChild(new FPS());
		}

		private function initBitmapCanvas(e : Event = null) : void
		{
			if(blurBmd != null)blurBmd.dispose();
			if(blurBmp != null)removeChild(blurBmp);
			blurBmd = new CanvasBitmapData(stage.stageWidth * 0.5, stage.stageHeight * 0.5);
			blurBmp = new Bitmap(blurBmd);
			blurBmp.width = stage.stageWidth;
			blurBmp.height = stage.stageHeight;
			addChildAt(blurBmp, 0);
			
			
			if(logo==null)
			{
				logo=new Logo();
				logo.blendMode=BlendMode.OVERLAY;
				addChildAt(logo, 1);
			}
			logo.x=stage.stageWidth/2;
			logo.y=stage.stageHeight/2;
		}

		private function onEnterFrame(event : Event) : void 
		{
			var color : uint = (Math.sin(r += ri) * 128 + 127) << 16 | (Math.sin(g += gi) * 128 + 127) << 8 | (Math.sin(b += bi) * 128 + 127) ;
			lineCanvas.graphics.clear();
			lineCanvas.graphics.lineStyle(2, color);
			var prevMid : Point = null;
			for(var i : int = 1;i < particleSystem.particles.length;i++)
			{
				//trace(particleSystem.particles.length);
				var pt1 : Object = {};
				var pt2 : Object = {};
				pt1.x = particleSystem.particles[i - 1].x;
				pt1.y = particleSystem.particles[i - 1].y;
				pt2.x = particleSystem.particles[i].x;
				pt2.y = particleSystem.particles[i].y;
				var midPoint : Point = new Point((pt1.x + pt2.x) / 2, (pt1.y + pt2.y) / 2);
				if(prevMid)
				{
					
					lineCanvas.graphics.moveTo(prevMid.x, prevMid.y);
					lineCanvas.graphics.curveTo(pt1.x, pt1.y, midPoint.x, midPoint.y);
				}
				else
				{
					lineCanvas.graphics.moveTo(pt1.x, pt1.y);
					lineCanvas.graphics.lineTo(midPoint.x, midPoint.y);
				}
				prevMid = midPoint;
			}
			blurBmd.draw(lineCanvas, null, null, BlendMode.ADD);
			blurBmd.blur(2, 2, 1);
			blurBmd.colorMod(-5, -5, -5, 0);
		}

		private function createFlow(event : MouseEvent) : void 
		{
			var brownForce : BrownForce = new BrownForce(1, 0.1);
			var p : Particle = new Particle(mouseX * 0.5, mouseY * 0.5, 1*30);
			p.addForce("browForce", brownForce);
			particleSystem.addParticle(p);
		}
	}
}
