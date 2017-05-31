package main.extension
{
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.resources.TextureResource;
	
	import cloud.core.interfaces.ICData;
	
	public class CTextureMaterial extends TextureMaterial
	{
		public var data0:ICData;
		
		public function CTextureMaterial(diffuseMap:TextureResource=null, opacityMap:TextureResource=null, alpha:Number=1)
		{
			super(diffuseMap, opacityMap, alpha);
		}
	}
}