package model
{
	import cloud.geometry.twod.MathUtil;
	
	import dic.KitchenGlobalDic;
	
	import interfaces.ICChainFurnitureVO;
	import interfaces.ICFurnitureVO;
	
	import model.vo.BaseChainFurnitureVO;

	/**
	 *  
	 * @author cloud
	 */
	public class BaseChainFurnitureModel extends BaseFurnitureSetModel
	{
		private var _sorptionNode:ICChainFurnitureVO;
		private var _canSorption:Boolean;
		
		protected var _root:ICChainFurnitureVO;
		public function BaseChainFurnitureModel()
		{
			super();
		}
		/**
		 * 判断是否吸附 
		 * @param part
		 * @return Boolean
		 * 
		 */		
		private function doSorption(current:BaseChainFurnitureVO):void
		{
			switch(_direction)
			{
				case KitchenGlobalDic.DIR_FRONT:
				case KitchenGlobalDic.DIR_BACK:
					if(current.position.x>_sorptionNode.position.x)
					{
						current.position.setTo(_sorptionNode.position.x+(current.length+_sorptionNode.length>>1)
							,_sorptionNode.position.y
							,_sorptionNode.position.z);
					}
					else
					{
						current.position.setTo(_sorptionNode.position.x-(current.length+_sorptionNode.length>>1)
							,_sorptionNode.position.y
							,_sorptionNode.position.z);
					}
					break;
				case KitchenGlobalDic.DIR_LEFT:
				case KitchenGlobalDic.DIR_RIGHT:
					if(current.position.y>_sorptionNode.position.y)
					{
						current.position.setTo(_sorptionNode.position.x,
							_sorptionNode.position.y+(current.width+_sorptionNode.width>>1),
							_sorptionNode.position.z);
					}
					else
					{
						current.position.setTo(_sorptionNode.position.x,
							_sorptionNode.position.y-(current.width+_sorptionNode.width>>1),
							_sorptionNode.position.z);
					}
					break;
				default:
					throw new Error(String("CabinetModel->direction 无效值！"+_direction));
					break;
			}
			addChainNode(current);
		}
		/**
		 *  执行删除节点
		 * @param node
		 * 
		 */		
		private function doRemoveNextNode(node:BaseChainFurnitureVO):void
		{
			if(node)
			{
				node.isInChain=false;
				doRemoveNextNode(node.next as BaseChainFurnitureVO);
				node.next=null;
			}
		}
		/**
		 * 添加链表节点 
		 * @param node
		 * 
		 */		
		protected function addChainNode(node:BaseChainFurnitureVO):void
		{
			_invalidProperty=true;
			if(_sorptionNode!=null)
				_sorptionNode.next=node;
			_sorptionNode=node;
			node.isInChain=true;
		}
		/**
		 * 删除链表节点 
		 * @param node
		 * 
		 */		
		protected function removeChainNode(node:BaseChainFurnitureVO):void
		{
			_invalidProperty=true;
			if(_root==node)
			{
				//当前节点是根节点
				_sorptionNode=_root;
				doRemoveNextNode(_root.next as BaseChainFurnitureVO);
				_root.next=null;
			}
			else
			{
				//当前节点不是根节点
				for(var tmp:ICChainFurnitureVO=_root;tmp;tmp=tmp.next)
				{
					if(tmp.next==node)
					{
						_sorptionNode=tmp;
						doRemoveNextNode(node as BaseChainFurnitureVO);
						tmp.next=null;
					}
				}
			}
		}
		protected function updateChainState(vo:BaseChainFurnitureVO):void
		{
			if(!_root)
			{
				_root=vo;
				addChainNode(vo);
			}
			updateCanSorption();
		}
		protected function updateCanSorption():void
		{
			if(_datas.length>1)
				_canSorption=true;
			else
				_canSorption=false;
		}
		/**
		 * 更新链表节点  
		 * @param vo
		 * @return Boolean 如果发生吸附操作返回true
		 * 
		 */			
		protected function updateChainNode(vo:BaseChainFurnitureVO):Boolean
		{
			if(_datas.length>1)
			{
				if(vo.isInChain && _canSorption)
				{
					removeChainNode(vo);
					_canSorption=false;
					return false;
				}
				var distance:Number=MathUtil.getDistanceByXYZ(_sorptionNode.position.x,_sorptionNode.position.y,_sorptionNode.position.z,vo.position.x,vo.position.y,vo.position.z);
				var dis:Number=(_sorptionNode.length+vo.length>>1)+KitchenGlobalDic.SORPTION_DISTANCE;
				//				trace("_sorptionPos:"+_sorptionNode.position.toString(),"currentPos:",vo.position.toString());
				//				trace("direction:"+_direction);
				if(_canSorption)
				{
					if(distance
						<= dis)
					{
						doSorption(vo);
						return true;
					}
				}
				else if(distance>dis)
				{
					_canSorption=true;
				}
			}
			return false;
		}
		/**
		 * 更新属性 
		 * 
		 */		
		override protected function updateProperty():void
		{
			var tmp:ICChainFurnitureVO;
			_length=_width=_height=0;
			switch(_direction)
			{
				//长度累加
				case KitchenGlobalDic.DIR_BACK:
				case KitchenGlobalDic.DIR_FRONT:
					for(tmp=_root;tmp;tmp=tmp.next)
					{
						tmp.direction=_direction;
						_length+=tmp.length;
						_width=Math.max(tmp.width,_width);
						_height=Math.max(tmp.height,_height);
					}
					//更新橱柜集合对象中心点
					if(_root.next)
					{
						if(_root.position.x>_root.next.position.x)
						{
							_combinePos.setTo(_root.position.x-(_length-_root.length>>1),
								_root.position.y,
								_root.position.z);
						}
						else
						{
							_combinePos.setTo(_root.position.x+(_length-_root.length>>1),
								_root.position.y,
								_root.position.z);
						}
					}
					else
					{
						_combinePos.copyFrom(_root.position);
					}
					break;
				//宽度累加
				case KitchenGlobalDic.DIR_LEFT:
				case KitchenGlobalDic.DIR_RIGHT:
					for(tmp=_root;tmp;tmp=tmp.next)
					{
						tmp.direction=_direction;
						_length=Math.max(tmp.length,_length);
						_width+=tmp.width;
						_height=Math.max(tmp.height,_height);
					}
					//更新橱柜集合对象中心点
					if(_root.next)
					{
						if(_root.position.y>_root.next.position.y)
						{
							_combinePos.setTo(_root.position.x,
								_root.position.y-(_width-_root.width>>1),
								_root.position.z);
						}
						else
						{
							_combinePos.setTo(_root.position.x,
								_root.position.y+(_width-_root.width>>1),
								_root.position.z);
						}
					}
					else
					{
						_combinePos.copyFrom(_root.position);
					}
					break;
			}
		}
	}
}