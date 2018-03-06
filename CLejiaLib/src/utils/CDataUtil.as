package utils
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3D;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	import cloud.core.utils.CVectorUtil;
	
	import main.dict.CParamDict;
	import main.extension.CQuotaObject;
	import main.model.vo.CRegionVO;
	import main.model.vo.CWallVO;

	/**
	 * 数据工具类
	 * @author cloud
	 */
	public class CDataUtil
	{
		private static var _Instance:CDataUtil;
		
		public static function get Instance():CDataUtil
		{
			return _Instance ||= new CDataUtil();
		}
		
		private var _groupCount:uint;
		private var _rectangle:Rectangle;
		
		public function CDataUtil()
		{
			_rectangle=new Rectangle();
		}
		/**
		 * 创建组ID 
		 * @return uint
		 * 
		 */		
		public function createGroupID():uint
		{
			return ++_groupCount;
		}
		/**
		 *  根据区域围点设置3D物体数据对象的尺寸信息
		 * @param sourceVo	物体数据对象
		 * @param regionPoints	区域围点
		 * @param thickness	物体数据对象的厚度
		 * 
		 */		
		public function setObject3DVoSizeByRegion(sourceVo:ICObject3D,regionPoints:Array,thickness:Number=0):void
		{
			var maxX:Number=int.MIN_VALUE,minX:Number=int.MAX_VALUE,maxY:Number=int.MIN_VALUE,minY:Number=int.MAX_VALUE;
			for each(var point:Point in regionPoints)
			{
				if(maxX<point.x)	maxX=point.x;
				if(minX>point.x)	minX=point.x;
				if(maxY<point.y)	maxY=point.y;
				if(minY>point.y)	minY=point.y;
			}
			sourceVo.length=maxX-minX;
			sourceVo.width=thickness;
			sourceVo.height=maxY-minY;
		}
		/**
		 * 根据相邻的两个3D围点Point,获取墙体数据对象
		 * @param wallVos
		 * @param pointA		
		 * @param pointB
		 * @return CWallVO
		 * 
		 */		
		public function getWallVoByRoundPoint3D(wallVos:Vector.<ICData>,pointA:Point,pointB:Point,is2DMode:Boolean=true):CWallVO
		{
			if(wallVos==null || wallVos.length==0) return null;
			var ya:Number;
			var yb:Number;
			if(is2DMode)
			{
				ya=-pointA.y;
				yb=-pointB.y;
			}
			else
			{
				ya=pointA.y;
				yb=pointB.y;
			}
			for each(var wallVo:CWallVO in wallVos)
			{
				if((wallVo.startPos.x==pointA.x && wallVo.startPos.y==ya && wallVo.endPos.x==pointB.x && wallVo.endPos.y==yb) ||
					(wallVo.startPos.x==pointB.x && wallVo.startPos.y==yb && wallVo.endPos.x==pointA.x && wallVo.endPos.y==ya))
					return wallVo;
			}
			return null;
		}
		/**
		 *  解析XML方案
		 * @param source
		 * @param parent
		 * 
		 */			
		public function deserizeXML(source:XML, parent:CBaseObject3DVO=null):void
		{
			if(source==null) return;
			var clsName:String;
			var cls:Class;
			var xmlList:XMLList=source.children();
			var len:int=xmlList.length();
			var vo:CBaseObject3DVO;
			for(var i:int=0; i<len; i++)
			{
				clsName=String(XML(xmlList[i]).name());
				cls=CParamDict.Instance.getParamDataTypeCls(clsName);
				vo=new cls(clsName);
				vo.deserialize(xmlList[i]);
				if(parent!=null)
					parent.addChild(vo);
				deserizeXML(xmlList[i],vo);
			}
		}
		/**
		 *  根据墙面索引获取墙面数据
		 * @param wallVos	墙面数据集合
		 * @param index	墙面索引
		 * @return 
		 * 
		 */		
		public function getWallVoByIndex(wallVos:Vector.<ICData>,index:int):CWallVO
		{
			for each(var wallVo:CWallVO in wallVos)
			{
				if(wallVo.indexIn2DMode>=0 && wallVo.indexIn2DMode==index)
				{
					return wallVo;
				}
			}
			return null;
		}
		/**
		 *	根据围点集合获取矩形区域 
		 * @param roundPoints	围点集合
		 * @return Rectangle
		 * 
		 */		
		public function getRectangleByRoundPoints(roundPoints:Array):Rectangle
		{
			var minX:Number=int.MAX_VALUE,minY:Number=int.MAX_VALUE;
			var maxX:Number=int.MIN_VALUE,maxY:Number=int.MIN_VALUE;
			for each(var pos:Vector3D in roundPoints)
			{
				if(minX>pos.x) minX=pos.x;
				if(minY>pos.y) minY=pos.y;
				if(maxX<pos.x) maxX=pos.x;
				if(maxY<pos.y) maxY=pos.y;
			}
			_rectangle.x=minX;
			_rectangle.y=minY;
			_rectangle.width=maxX-minX;
			_rectangle.height=maxY-minY;
			return _rectangle;
		}
		/**
		 * 计算单元件长度的缩放比例 
		 * @param unitLength
		 * @param wallLength
		 * @return Number
		 * 
		 */		
		public function calculationUnitScaleRate(unitLength:Number,wallLength:uint):Number
		{
			var scaleRate:Number;
			var value:Number=wallLength/unitLength;
			var num:int=wallLength/unitLength;
			if(value>num)
			{
				num++;
				scaleRate=wallLength/num/unitLength;
			}
			else
			{
				scaleRate=1;
			}
			return scaleRate;
		}
//		/**
//		 * 将报价数据序列化成XML 
//		 * @param meshes
//		 * @return XML
//		 * 
//		 */		
//		public function serializeClapboardQuotesToXML(meshes:Vector.<L3DMesh>):XML
//		{
//			for each(var mesh:L3DMesh in meshes)
//			{
//				if(mesh.userData2!=null)
//				{
//					for
//				}
//			}
//		}

		/**
		 * 将算料请求数据序列化成XML 
		 * @param source
		 * @return XML
		 * 
		 */		
		public function serializeNestingXML(source:Array):XML
		{
			var xml:XML=<Lejia type="TileCuttingStock"></Lejia>;
			var elemXml:XML;
			var elemObj:Object;
			var listArr:Array;
			var listObj:Object;
			for(var i:int=0; i<source.length; i+=2)
			{
				elemObj=source[i];
				elemXml=<Elem W={elemObj.length} L={elemObj.height} TextureNo={elemObj.order}></Elem>;
				xml.appendChild(elemXml);
				listArr=source[i+1];
				for(var j:int=0; j<listArr.length; j++)
				{
					listObj=listArr[j];
					elemXml.appendChild(
						<list id={j} type="Rect">
     						<value l={listObj.height} w={listObj.length}/>
						</list>);
				}
			}
			return xml;
		}
		/**
		 * 保存一个算料请求数据 
		 * @param texOrder	纹理的顺序编号
		 * @param length		母版长度
		 * @param height		母版高度
		 * @param subLength		子板的长度
		 * @param subHeight		子板的高度
		 * @param output	请求数据容器对象
		 * 
		 */		
		public function cacheOneNestingRequestVo(texOrder:int,length:Number,height:Number,subBoards:Array,output:Array):void
		{
			output.push({order:texOrder,length:length,height:height});
			output.push(subBoards);
		}
		public function calculationBoardTotalPieces(sourceArr:Vector.<CQuotaObject>,outPutObj:Object):void
		{
			var pieces:int;
			var totalArea:Number=0;
			for each(var obj:CQuotaObject in sourceArr)
			{
				totalArea+=obj.totalLength*obj.totalHeight;
			}
			pieces=totalArea/(obj.Length*obj.Height);
			var rand:int=totalArea%(obj.Length*obj.Height);
			if(rand>0)
				pieces++;
			outPutObj.Piece=pieces;
			outPutObj.Area=(totalArea*0.000001).toFixed(2);
		}

		private function sortNestingBoardFunc(objA:CQuotaObject,objB:CQuotaObject):int
		{
			if(objA.Length*objA.Height>=objB.Length*objB.Height)
			{
				return -1;
			}
			return 1;
		}
		/**
		 * 创建3D对象数据 
		 * @param type
		 * @param uniqueID
		 * @param parentID
		 * @param length
		 * @param width
		 * @param height
		 * @param x
		 * @param y
		 * @param z
		 * @param rotation
		 * 
		 */		
		public function createObject3DData(type:uint,uniqueID:String,parentID:String,length:Number,width:Number,height:Number,x:Number,y:Number,z:Number,rotation:Number,isDegree:Boolean=true):CBaseObject3DVO
		{
//			var vo:CObject3DVO = doCreateObject3DData(type);
			var cls:Class=CParamDict.Instance.getParamDataTypeCls(CParamDict.Instance.getTypeClassName(type));
			var vo:CBaseObject3DVO = new cls();	
			vo.uniqueID=uniqueID;
			vo.type=type;
			vo.parentID=parentID;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			vo.x=x;
			vo.y=y;
			vo.z=z;
			CVectorUtil.Instance.calculateDirectionByRotation(rotation,vo.direction,isDegree);
			CVector.Normalize(vo.direction);
			return vo;
		}
		public function createRegionPlanVO(type:uint,uniqueID:String,parentID:String,length:Number,width:Number,height:Number,x:Number,y:Number,z:Number,rotation:Number,isDegree:Boolean=true):CRegionVO
		{
			var vo:CRegionVO = new CRegionVO();
			vo.uniqueID=uniqueID;
			vo.type=type;
			vo.parentID=parentID;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			vo.x=x;
			vo.y=y;
			vo.z=z;
			CVectorUtil.Instance.calculateDirectionByRotation(rotation,vo.direction,isDegree);
			CVector.Normalize(vo.direction);
			return vo;
		}
		public function createWall(type:uint,uniqueID:String,parentID:String,length:Number,width:Number,height:Number,x:Number,y:Number,z:Number,rotation:Number,isDegree:Boolean=true):CWallVO
		{
			var vo:CWallVO = new CWallVO();	
			vo.uniqueID=uniqueID;
			vo.type=type;
			vo.parentID=parentID;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			vo.x=x;
			vo.y=y;
			vo.z=z;
			CVectorUtil.Instance.calculateDirectionByRotation(rotation,vo.direction,isDegree);
			CVector.Normalize(vo.direction);
			return vo;
		}
	}
}