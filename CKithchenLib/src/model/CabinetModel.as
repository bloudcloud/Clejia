package model
{
	import cloud.geometry.twod.MathUtil;
	
	import dic.KitchenGlobalDic;
	
	import flash.geom.Vector3D;
	
	import model.vo.CabinetVO;
	import model.vo.ShelterVO;
	import model.vo.TableBoardVO;

	/**
	 *  橱柜数据模型类
	 * @author cloud
	 */
	public class CabinetModel extends BaseChainFurnitureModel
	{
		public static var ID:uint;
		private var _shelterModel:ShelterModel;

		public var leftUpWallPos:Vector3D;
		public var rightUpWallPos:Vector3D;
		public var leftDownWallPos:Vector3D;
		public var rightDownWallPos:Vector3D;
		
		public function CabinetModel()
		{
			_shelterModel=new ShelterModel();
			
			leftUpWallPos=new Vector3D();
			rightUpWallPos=new Vector3D();
			leftDownWallPos=new Vector3D();
			rightDownWallPos=new Vector3D();
		}
		/**
		 * 创建单柜数据 
		 * @param furnitureID
		 * @param furnitureType
		 * @param length
		 * @param width
		 * @param height
		 * 
		 */		
		public function createCabinetVO(furnitureID:String,furnitureType:uint,length:uint,width:uint,height:uint):void
		{
			var vo:CabinetVO = new CabinetVO();
			vo.uniqueID = furnitureID;
			vo.type = furnitureType;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			vo.direction=_direction;

			addFurnitureVO(vo);
			updateChainState(vo);
		}
		/**
		 * 根据ID删除单柜数据 
		 * @param furnitureID
		 * 
		 */		
		public function deleteCabinetVO(furnitureID:String):void
		{
			var vo:CabinetVO=getFurnitureVOByID(furnitureID) as CabinetVO;
			if(vo && vo is CabinetVO && _root!=vo)
				removeChainNode(vo as CabinetVO);
			removeFurnitureVO(vo);
			updateCanSorption();
		}
		/**
		 * 创建台面数据 
		 * @param length
		 * @param width
		 * @param height
		 * @param combinePos
		 * @return TableBoardVO
		 * 
		 */		
		public function createTableBoardVO(length:uint,width:uint,height:uint,combinePos:Vector3D):TableBoardVO
		{
			var vo:TableBoardVO=new TableBoardVO();
			vo.uniqueID=(++ID).toString();
			vo.direction=direction;
			vo.width=width;
			vo.height=height;
			vo.position.copyFrom(combinePos);
			vo.position.z+=this.height+(KitchenGlobalDic.TABLEBOARD_HEIGHT>>1);
			addFurnitureVO(vo);
			if(_shelterModel.isCreated)
			{
				vo.length=_shelterModel.shelterLength+length;
				switch(vo.direction)
				{
					case KitchenGlobalDic.DIR_FRONT:
					case KitchenGlobalDic.DIR_BACK:
						vo.position.x=0;
						break;
					case KitchenGlobalDic.DIR_LEFT:
					case KitchenGlobalDic.DIR_RIGHT:
						vo.position.y=0;
						break;
				}
			}
			else
			{
				vo.length=length;
			}
			return vo;
		}
		/**
		 * 删除台面数据 
		 * @param id
		 * 
		 */		
		public function deleteTableBoardVO(id:String):void
		{
			var vo:TableBoardVO = getFurnitureVOByID(id) as TableBoardVO;
			removeFurnitureVO(vo);
		}
		/**
		 * 创建挡板数据 
		 * @return ShelterVO
		 * 
		 */		
		public function createShelterVOs():Vector.<ShelterVO>
		{
			var vos:Vector.<ShelterVO>=_shelterModel.createShelter(direction,leftUpWallPos,rightUpWallPos,leftDownWallPos,rightDownWallPos,_combinePos,length,width,height);
			if(vos)
			{
				for each(var vo:ShelterVO in vos)
				{
					addFurnitureVO(vo);
				}
			}
			return vos;
		}
		/**
		 * 根据id集合删除挡板数据集合 
		 * @param ids
		 * 
		 */		
		public function deleteShelterVOs(ids:Vector.<String>):void
		{
			var vo:ShelterVO;
			for each(var id:String in ids)
			{
				vo=getFurnitureVOByID(id) as ShelterVO;
				removeFurnitureVO(vo);
			}
			_shelterModel.isCreated=false;
		}
		override public function excuteMove(furnitureID:String,furnitureDir:int,outputPos:Vector3D):Boolean
		{
			var vo:CabinetVO=getFurnitureVOByID(furnitureID) as CabinetVO;
			if(vo==null) return false;
			vo.position.copyFrom(outputPos);
			direction=furnitureDir;
			if(updateChainNode(vo))
			{
				outputPos.copyFrom(vo.position);
				return true;
			}
			vo.position.copyFrom(outputPos);
			return false;
		}
	}
}
import cloud.geometry.twod.MathUtil;

import dic.KitchenGlobalDic;

import flash.geom.Vector3D;

import model.CabinetModel;
import model.vo.ShelterVO;
/**
 *  挡板数据模型类
 * @author cloud
 * 
 */
class ShelterModel
{
	public var isCreated:Boolean;
	private var _shelterLength:Number;
	public function get shelterLength():Number
	{
		return _shelterLength;
	}
	/**
	 * 在X轴方向创建一组挡板  
	 * @param dir
	 * @param leftWallPos
	 * @param rightWallPos
	 * @param combinePos
	 * @param cabinetLength
	 * @param cabinetWidth
	 * @param cabinetHeight
	 * @param rotation
	 * @return Vector.<ShelterVO>
	 * 
	 */	
	private function createShelterByX(dir:int,leftWallPos:Vector3D,rightWallPos:Vector3D,combinePos:Vector3D,cabinetLength:Number,cabinetWidth:Number,cabinetHeight:Number,rotation:Number):Vector.<ShelterVO>
	{
		var vos:Vector.<ShelterVO>=new Vector.<ShelterVO>();
		var vo:ShelterVO;
		var shelterLength:Number;
		_shelterLength=0;
		//左侧
		shelterLength=combinePos.x-leftWallPos.x-cabinetLength*.5;
		if(shelterLength>0)
		{
			vo=doCreateShelterByX(dir,shelterLength,cabinetWidth,cabinetHeight,combinePos,rotation);
			vo.position.x=leftWallPos.x+shelterLength*.5;
			vos.push(vo);
			_shelterLength+=shelterLength;
		}
		//右侧
		shelterLength=rightWallPos.x-combinePos.x-cabinetLength*.5;
		if(shelterLength>0)
		{
			vo=doCreateShelterByX(dir,shelterLength,cabinetWidth,cabinetHeight,combinePos,rotation);
			vo.position.x=rightWallPos.x-shelterLength*.5;
			vos.push(vo);
			_shelterLength+=shelterLength;
		}
		return vos;
	}
	/**
	 * 在Y轴方向上创建一组挡板  
	 * @param dir
	 * @param upWallPos
	 * @param downWallPos
	 * @param combinePos
	 * @param cabinetLength
	 * @param cabinetWidth
	 * @param cabinetHeight
	 * @param rotation
	 * @return Vector.<ShelterVO>
	 * 
	 */		
	private function createShelterByY(dir:int,upWallPos:Vector3D,downWallPos:Vector3D,combinePos:Vector3D,cabinetLength:Number,cabinetWidth:Number,cabinetHeight:Number,rotation:Number):Vector.<ShelterVO>
	{
		var vos:Vector.<ShelterVO>=new Vector.<ShelterVO>();
		var vo:ShelterVO;
		var shelterLength:Number;
		_shelterLength=0;
		shelterLength=combinePos.y-upWallPos.y-(length>>1);
		if(shelterLength>0)
		{
			vo=doCreateShelterByY(dir,shelterLength,cabinetWidth,cabinetHeight,combinePos,rotation);
			vo.position.y=upWallPos.y+(shelterLength>>1);
			vos.push(vo);
			_shelterLength+=shelterLength;
		}
		
		shelterLength=downWallPos.y-combinePos.y-(length>>1);
		if(shelterLength)
		{
			vo=doCreateShelterByY(dir,shelterLength,cabinetWidth,cabinetHeight,combinePos,rotation);
			vo.position.y=downWallPos.y-(shelterLength>>1);
			vos.push(vo);
			_shelterLength+=shelterLength;
		}
		return vos;
	}
	/**
	 * 执行创建X方向上的挡板 
	 * @param dir
	 * @param length
	 * @param cabinetWidth
	 * @param cabinetHeight
	 * @param combinePos
	 * @param rotation
	 * @return 
	 * 
	 */		
	private function doCreateShelterByX(dir:int,length:Number,cabinetWidth:Number,cabinetHeight:Number,combinePos:Vector3D,rotation:Number):ShelterVO
	{
		var vo:ShelterVO=new ShelterVO();
		vo.uniqueID=(++CabinetModel.ID).toString();
		vo.direction=dir;
		vo.length=length;
		vo.width=cabinetHeight;
		vo.height=KitchenGlobalDic.SHELTER_WIDTH;
		vo.rotation=MathUtil.toRadians(rotation);
		vo.position.y=combinePos.y-cabinetWidth*.5;
		vo.position.z=combinePos.z+cabinetHeight*.5;
		return vo;
	}
	/**
	 * 执行创建Y方向的挡板 
	 * @param length	挡板的长度
	 * @param material	挡板的材质
	 * @param rotation	挡板的旋转角度
	 * @return Plane
	 * 
	 */		
	private function doCreateShelterByY(dir:int,length:Number,cabinetWidth:Number,cabinetHeight:Number,combinePos:Vector3D,rotation:Number):ShelterVO
	{
		var vo:ShelterVO=new ShelterVO();
		vo.uniqueID=(++CabinetModel.ID).toString();
		vo.direction=dir;
		vo.length=length;
		vo.width=cabinetHeight;
		vo.height=KitchenGlobalDic.SHELTER_WIDTH;
		vo.rotation=MathUtil.toRadians(rotation);
		vo.position.x=combinePos.y-cabinetWidth*.5;
		vo.position.z=combinePos.z+cabinetHeight*.5;
		return vo;
	}
	/**
	 * 创建挡板,返回挡板数据集合
	 * @param dir
	 * @param leftUpWallPos		
	 * @param rightUpWallPos
	 * @param leftDownWallPos
	 * @param rightDownWallPos
	 * @param combinePos
	 * @param cabinetLength
	 * @param cabinetWidth
	 * @param cabinetHeight
	 * @return Vector.<ShelterVO>
	 * 
	 */	
	public function createShelter(dir:int,leftUpWallPos:Vector3D,rightUpWallPos:Vector3D,leftDownWallPos:Vector3D,rightDownWallPos:Vector3D,
								  combinePos:Vector3D,cabinetLength:Number,cabinetWidth:Number,cabinetHeight:Number):Vector.<ShelterVO>
	{
		var vos:Vector.<ShelterVO>;
		switch(dir)
		{
			case KitchenGlobalDic.DIR_FRONT:
				vos=createShelterByX(dir,leftUpWallPos,rightUpWallPos,combinePos,cabinetLength,cabinetWidth,cabinetHeight,90);
				break;
			case KitchenGlobalDic.DIR_BACK:
				vos=createShelterByX(dir,leftDownWallPos,rightDownWallPos,combinePos,cabinetLength,cabinetWidth,cabinetHeight,-90);
				break;
			case KitchenGlobalDic.DIR_LEFT:
				vos=createShelterByY(dir,leftUpWallPos,leftDownWallPos,combinePos,cabinetLength,cabinetWidth,cabinetHeight,-90);
				break;
			case KitchenGlobalDic.DIR_RIGHT:
				vos=createShelterByY(dir,rightUpWallPos,rightDownWallPos,combinePos,cabinetLength,cabinetWidth,cabinetHeight,90);
				break;
		}
		if(vos)
			isCreated=true;
		return vos;
	}
}